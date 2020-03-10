# zsh devtools

This project aims at providing a small set of shell commands to help optimizing your daily development workflow when working on PHP projects such as [Laravel](https://laravel.com) and [CraftCMS](https://craftcms.com).

The package contains some useful commands such as `project:create` which takes you through the process of installing a brand new project using only one command. There is also a configuration file included that allows you to customize these scripts to your own preferences and needs.

**Note:** These scripts are meant to be used on a Linux OS with [zsh already installed](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH).

## Dependencies

The scripts require these technologies to be installed on your local development machine:

- [zsh](https://www.zsh.org/)
- [PHP Composer](https://getcomposer.org/)
- [MySQL Client](https://www.mysql.com/)
- [Laravel Valet](https://laravel.com/docs/6.x/valet) (optional)

## Installation

1. Clone this repository somewhere on your machine.
2. Rename the **config.example.zsh** file to **config.zsh** and edit the configurations for your dev environment.
3. Edit your **~/.zshrc** file to include the bootstrap script (i.e. `source /path/to/zsh-devtools/bootstrap.zsh`)
4. Run the command `mysql:create_login` to create a local MySQL authentication file.
5. Optionally run the command `mysql:test_login` to validate that the previous operation worked.

## Usage

Here is a list of some available commands. To see the full list, you should have a look at all the functions located under the **includes/** folder. Everything should be well documentated.

### Database
- mysql:create_login
- mysql:test_login
- db:create
- db:drop
- db:dump
- db:copy
- db:list

### Projects
- project:create
- project:delete
