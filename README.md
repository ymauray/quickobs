<p align="center">
  <img src="assets/resources/quickobs_256.png" alt="quickobs">
  <br />
  <tt>quickobs</tt>
</p>

<p align="center">
  <b>
    A <tt>Flutter</tt> tool to quickly download and run Martin Wimpress' <a href="https://github.com/wimpysworld/obs-studio-portable">OBS Studio Portable</a>.
  </b>
</p>

## Introduction

`QuickOBS` tracks the latest release of [OBS Studio Portable](https://github.com/wimpysworld/obs-studio-portable), Martin Wimpress' own build of OBS Studio. With `QuickOBS`, it is easy to install the latest release of OBS Studio Portable, run it, rename it, update it, and remove it.

------------------------------------

## Installation

Once [`deb-get`](https://github.com/wimpysworld/deb-get) supports `QuickOBS`, you will be able to use [`deborah`](https://github.com/ymauray/deborah) to install it. 

In the meantime, download the .deb from the [release](https://github.com/ymauray/quickobs/releases) page, and install it using this command :
```sh
$ sudo apt install ./quickobs_xxxxxx.deb
```
------------------------------------

## Usage

Run `quickobs` from your applications menu. It will check on GitHub the latest release of `OBS Studio Portable`, and present the release number, and a button to install that particular release.

It will also check for any instance of `OBS Studio Portable` present in the root folder specified on the main page.

For each instance, it is possible to run it, rename it, update it, and remove it, using the popup menu button on the right side of the row.

------------------------------------

## Dependencies

Although `OBS Studio Portable` is ... well ... portable, it still requires some dependencies to run. The first time `OBS Studio Portable` is installed, it is necessary to open a terminal, go in the folder where `OBS Studio Portable` has been installed, and run `./obs-dependencies`.

Please check to [`OBS Studio Portable`](https://github.com/wimpysworld/obs-studio-portable) for more information.

------------------------------------

## Contributing

Contributions are welcome, however, some rules must be followed to prevent chaos.

1. **All commits must be signed.** Although this might be seen as a barrier for contributors, it is  something that must be done only once, and that will bring value to any future contribution. 
2. **Pull requests should be named properly.** Again, what can be seen as an hindrance will, in the long run, improve the quality of the contributions, and shorten the time it takes to merge relevent pull requests.

**Signing your commits**

Have a look at the [github documentation](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits), you will find everything you need. If you use [GitKraken](https://www.gitkraken.com/) - and you should - then it will help you create your keys and set everything up for you.

**Naming your pull requests**

We use the [Conventional Commits](https://www.conventionalcommits.org) specification to check that the pull request - not the individual commits - are properly named. For that, we use a GitHub action that will check the pull request automatically.

Examples for valid PR titles:
 - fix: Correct typo.
 - feat: Add support for Node 12.
 - refactor!: Drop support for Node 6.
 - feat(ui): Add Button component.

Note that since PR titles only have a single line, you have to use the ! syntax for breaking changes.

Available types:
 - feat: A new feature
 - fix: A bug fix
 - docs: Documentation only changes
 - style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
 - refactor: A code change that neither fixes a bug nor adds a feature
 - perf: A code change that improves performance
 - test: Adding missing tests or correcting existing tests
 - build: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
 - chore: Other changes that don't modify src or test files
 - revert: Reverts a previous commit
