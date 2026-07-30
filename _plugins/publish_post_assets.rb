# frozen_string_literal: true

require 'fileutils'

# Jekyll treats `_posts` as a special source directory and does not publish
# arbitrary files stored below it. Copy `_posts/assets/**` into the generated
# site's `/assets/**` directory so Markdown links such as `./assets/image.png`
# keep working both in local editors and on GitHub Pages.
Jekyll::Hooks.register :site, :post_write do |site|
  source_root = File.join(site.source, '_posts', 'assets')
  next unless Dir.exist?(source_root)

  destination_root = File.join(site.dest, 'assets')
  copied = 0

  Dir.glob(File.join(source_root, '**', '*')).each do |source|
    next unless File.file?(source)

    relative = source.delete_prefix("#{source_root}#{File::SEPARATOR}")
    destination = File.join(destination_root, relative)
    FileUtils.mkdir_p(File.dirname(destination))
    FileUtils.cp(source, destination)
    copied += 1
  end

  Jekyll.logger.info('Post assets:', "published #{copied} file(s) from _posts/assets")
end
