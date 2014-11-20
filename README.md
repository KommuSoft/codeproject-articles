    Title:       The "readme" article
    Author:      KommuSoft
    Email:       (hidden)
    Language:    Mainly Markdown, and some `bash`, html and css.
    Platform:    Any platform
    Technology:  Markdown
    Level:       Beginner
    Description: Enter a brief description of your article
    Section      Web Development
    SubSection   HTML / CSS
    License:     The GNU General Public License (GPLv3)

## Introduction

This repository enables one to prepare, modify,... articles for [CodeProject](http://www.codeproject.com/) without the need of actually modifying the given html template. One can simply write an `.md` file and run `make file.md` to convert it into a CodeProject article.


## Dependencies (installation)

The repository depends on `bash`, `make`, `basename`, `cat` and `pandoc`. On a *Ubuntu/Debian* machine, you can ensure all these commands exist by running the following command:

    sudo apt-get install coreutils make bash pandoc

to install all required packages.

## Generating CodeProject articles

First you need to write a CodeProject article in Markdown. You do this by creating a `.md` file in the root of this document, for instance `article.md`. You can write the article with any type of editor (for instance `vim`, or *ReText*).

Next you run:

    make article.htm

Where you replace `article.htm` with the name of your article (followed by **`.htm`**, not `.md`). The program will generate a .htm page formatted as a *CodeProject* article in the root directory, like this [one](README.htm).

Next you submit your article [*CodeProject*](http://www.codeproject.com/script/Articles/Submit.aspx).

You can build all articles in the root repository in bulk by running:

    make all

Or even shorter

    make

## Advantages

The aim of this package is to enable an author to simply write his/her article, without having to worry that the header is formatted well, downloading the template package. As this repository will develop further, more sophisticated checking,... can be implemented.

We think Markdown is more suited to write articles and pages, since one focuses more on the content than on the code surrounding that content. Markdown is an open format with editors like *ReText*. This holds for HTML as well, but HTML editors tend to provide an overwhelming WYSIWYG with features *CodeProject* articles probably will never need. Furthermore it is guaranteed to keep the page header and footer untouched.

One of the development we target is the creation of a `.pdf` containing all the articles in a repository.