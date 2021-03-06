require 'asciidoctor' unless defined? ::Asciidoctor::VERSION
require 'asciidoctor-diagram' unless defined? ::Asciidoctor::Diagram::VERSION

module Asciidoctor
    module Diagram
        # @private
        module CliGenerator
            def generate_stdin(tool, format, code)
                tool_name = File.basename(tool)

                target_file = Tempfile.new([tool_name, ".#{format}"])
                begin
                    target_file.close

                    opts = yield tool, target_file.path

                    generate(opts, target_file, :stdin_data => code)
                ensure
                    target_file.unlink
                end
            end

            def generate_file(tool, input_ext, output_ext, code)
                tool_name = File.basename(tool)

                source_file = Tempfile.new([tool_name, ".#{input_ext}"])
                begin
                    File.write(source_file.path, code)

                    target_file = Tempfile.new([tool_name, ".#{output_ext}"])
                    begin
                        target_file.close

                        opts = yield tool, source_file.path, target_file.path

                        generate(opts, target_file)
                    ensure
                        target_file.unlink
                    end
                ensure
                    source_file.unlink
                end
            end

            def generate(opts, target_file, open3_opts = {})
                case opts
                    when Array
                        args = opts
                        out_file = nil
                    when Hash
                        args = opts[:args]
                        out_file = opts[:out_file]
                    else
                        raise "Block passed to generate_file should return an Array or a Hash"
                    end

                output = ::Asciidoctor::Diagram::Cli.run(*args, open3_opts)

                raise "#{args[0]} failed: #{output}" unless File.exist?(out_file || target_file.path)

                if out_file
                    File.rename(out_file, target_file.path)
                end

                File.binread(target_file.path)
            end
        end

        # @private
        module Stupid
            include CliGenerator
            include Which

            def self.included(mod)
                [:png, :svg].each do |f|
                    mod.register_format(f, :image) do |parent, source|
                        stupid(parent, source, f)
                    end
                end
            end

            def stupid(parent, source, format)
                generate_stdin(which(parent, 'stupid'), format.to_s, source.to_s) do |tool_path, output_path|
                    args = [tool_path, 'render', format.to_s, Platform.native_path(output_path).chomp(".#{format.to_s}")]
                    args
                end
            end
        end

        class StupidBlockProcessor < Extensions::DiagramBlockProcessor
            include Stupid
        end

        class StupidBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
            include Stupid
        end
    end
end

Asciidoctor::Extensions.register do
    block Asciidoctor::Diagram::StupidBlockProcessor, :stupid
    block_macro Asciidoctor::Diagram::StupidBlockMacroProcessor, :stupid
end