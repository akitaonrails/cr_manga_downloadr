# Crystal - MangaReader Downloader

I did a Ruby version of a MangaReader crawler using Typhoeus. The code got really convoluted and I never properly refactored it.

The original code is here:

    https://github.com/akitaonrails/manga-downloadr

I also did a better structured Elixir version here:

    https://github.com/akitaonrails/ex_manga_downloadr

## Installation

You will need to install ImageMagick in your system (to resize images to Kindle format and merge them into PDF volumes). Refer to your system's particular install. In Ubuntu, simply do:

    sudo apt-get install imagemagick

To set up the development environment install the dependencies:

    crystal deps
    crystal build src/cr_manga_downloadr.cr --release

## Usage

Once you have the compiled binary just use like this:

    ./cr_manga_downloadr -u http://www.mangareader.net/onepunch-man -d /tmp/onepunch-man

In this example, all the pages of the "One Punch Man" will be downloaded to the directory "/tmp/onepunch-man" and they will have the following filename format:

    /tmp/onepunch-man/Onepunch-Man-Chap-00038-Pg-00011.jpg

Chapters and Pages numbers will be properly left-padded with zeroes so the filesystem can sort them correctly.

## Development

You can run the specs like this:

    crystal spec

## Contributing

1. Fork it ( https://github.com/akitaonrails/cr_manga_downloadr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [AkitaOnRails](https://github.com/akitaonrails) - creator, maintainer
