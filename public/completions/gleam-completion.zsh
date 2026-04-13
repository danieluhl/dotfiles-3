#compdef _gleam gleam

function _gleam {
    local line

    _arguments -C \
        "1:command:->commands" \
        "*::arg:->args"


    case "$state" in
        commands)
            local commands
            commands=(
                'add:Add new dependencies'
                'build:Build the project'
                'check:Type check the project'
                'clean:Delete any build artifacts for this project'
                'deps:Work with dependency packages'
                'dev:Run the project development entrypoint'
                'docs:Render HTML documentation for the package'
                'export:Export something useful from the Gleam project'
                'fix:Rewrite deprecated Gleam code'
                'format:Format source code'
                'help:Print this message or the help of the given subcommand(s)'
                'hex:Work with the Hex package manager'
                'new:Create a new project'
                'publish:Publish the project to the Hex package repository'
                'remove:Remove project dependencies'
                'run:Run the project'
                'shell:Start an Erlang REPL with the Gleam code loaded'
                'test:Run the project tests'
                'update:Update dependency packages to their latest versions'
            )
            _describe -t commands 'command' commands && ret=0
            ;;
        args)
            case $line[1] in
                add) _gleam_add;;
                build) _gleam_build;;
                check) _gleam_check;;
                clean);;
                deps) _gleam_deps;;
                dev) _gleam_dev;;
                docs) _gleam_docs;;
                export) _gleam_export;;
                fix);;
                format) _gleam_format;;
                help);;
                hex) _gleam_hex;;
                new) _gleam_new;;
                publish) _gleam_publish;;
                remove) _list_packages;;
                run) _gleam_run;;
                shell);;
                test) _gleam_test;;
                update) _list_packages;;
            esac
    esac
}

function _gleam_add {
    _arguments \
        '--dev:[Add the packages as dev-only dependencies]' \
        ':package name:->packages'

    case "$state" in
        packages) _message 'package name';;
    esac
}

function _gleam_build {
    _arguments \
        '(-t --target)'{-t,--target}'[The platform to target]:target:(erlang javascript)' \
        '--warnings-as-errors[Consider the build failed if the package contains any warnings]' \
        '--no-print-progress[Don'\''t print progress information]'
}


function _gleam_check {
    _arguments \
        '(-t --target)'{-t,--target}'[The platform to target]:target:(erlang javascript)'
}

function _gleam_deps {
    local line

    _arguments -C \
        "1:command:->commands" \
        "*::arg:->args"

    case "$state" in
        commands)
            local commands
            commands=(
                'list:List all dependency packages'
                'download:Download all dependency packages'
                'outdated:List all outdated dependencies'
                'update:Update dependency packages to their latest versions'
                'tree:Tree of all the dependency packages'
            )
            _describe -t commands 'command' commands && ret=0
            ;;
        args)
            case $line[1] in
                list);;
                download);;
                outdated);;
                update) _list_packages;;
                tree) _gleam_deps_tree;;
            esac
    esac
}

function _gleam_deps_tree {
    _arguments \
        '(-p --package -i --invert)'{-p,--package}'[Package to be used as the root of the tree]:package:_list_packages' \
        '(-p --package -i --invert)'{-i,--invert}'[Invert the tree direction and focus on the given package]:invert:_list_packages'
}

function _list_packages {
    if [[ -f gleam.toml ]]; then
        command='
        /^\[dependencies\]/,/^\[/ {
            /=/ {
                s/=.*//
                p
            }
        }
        /^\[dev_dependencies\]/,/^\[/ {
            /=/ {
                s/=.*//
                p
            }
        }
        '
        deps=($(sed -n "$command" gleam.toml))

        if [ ${#deps[@]} -gt 0 ]; then
            _values 'package' "${deps[@]}"
        fi
    fi
}

function _gleam_dev {
    _arguments \
        '(-t --target)'{-t,--target}'[The platform to target]:target:(erlang javascript)' \
        '--runtime[The runtime to target]:runtime:(nodejs deno bun)'
}

function _gleam_docs {
    local line

    _arguments -C \
        "1:command:->commands" \
        "*::arg:->args"

    case "$state" in
        commands)
            local commands
            commands=(
                'build:Render HTML docs locally'
                'publish:Publish HTML docs to HexDocs'
                'remove:Remove HTML docs from HexDocs'
            )
            _describe -t commands 'command' commands && ret=0
            ;;
        args)
            case $line[1] in
                build) _gleam_docs_build;;
                publish);;
                remove) _gleam_docs_remove;;
            esac
    esac
}

function _gleam_docs_build {
    _arguments \
        '(-t --target)'{-t,--target}'[The platform to target]:target:(erlang javascript)' \
        '--open[Opens the docs in a browser after rendering]'
}

function _gleam_docs_remove {
    _arguments \
        '--package[The name of the package]:package:_nothing' \
        '--version[The version of the docs to remove]:version:_nothing'
}

function _nothing {
    return
}

function _gleam_export {
    local line

    _arguments -C \
        "1:command:->commands" \
        "*::arg:->args"

    case "$state" in
        commands)
            local commands
            commands=(
                'erlang-shipment:Precompiled Erlang, suitable for deployment'
                'hex-tarball:The package bundled into a tarball, suitable for publishing to Hex'
                'javascript-prelude:The JavaScript prelude module'
                'typescript-prelude:The TypeScript prelude module'
                'package-interface:Information on the modules, functions, and types in the project in JSON format'
                'package-information:Package information (gleam.toml) in JSON format'
            )
            _describe -t commands 'command' commands && ret=0
            ;;
        args)
            case $line[1] in
                erlang-shipment);;
                hex-tarball);;
                javascript-prelude);;
                typescript-prelude);;
                package-interface) _gleam_export_package_interface;;
                package-information) _gleam_export_package_information;;
            esac
    esac
}

function _gleam_export_package_interface {
    _arguments \
        '--out[The path to write the JSON file to]:out:_files'
}


function _gleam_export_package_information {
    _arguments \
        '--out[The path to write the JSON file to]:out:_files'
}

function _gleam_format {
    _arguments \
        '--stdin[Read source from standard-input]' \
        '--check[Only check if inputs are formatted correctly, erroring if they are not]' \
        '*:files or directories:_files'
}

function _gleam_hex {
    local line

    _arguments -C \
        "1:command:->commands" \
        "*::arg:->args"

    case "$state" in
        commands)
            local commands
            commands=(
                'retire:Retire a release from Hex'
                'unretire:Un-retire a release from Hex'
                'revert:Revert a release from Hex'
                'owner:Deal with package ownership'
                'authenticate:Log in to Hex. Replaces the credentials with new ones if already logged in'
            )
            _describe -t commands 'command' commands && ret=0
            ;;
        args)
            case $line[1] in
                retire) ;;
                unretire) ;;
                revert) _gleam_hex_revert;;
                owner) _gleam_hex_owner;;
                authenticate) ;;
            esac
    esac
}

function _gleam_hex_revert {
    _arguments \
        '--package[The name of the package]:package:_nothing' \
        '--version[The version of the docs to remove]:version:_nothing'
}

function _gleam_hex_owner {
    local line

    _arguments -C \
        "1:command:->commands" \
        "*::arg:->args"

    case "$state" in
        commands)
            local commands
            commands=(
                'transfer:Transfers ownership of the given package to a new Hex user'
            )
            _describe -t commands 'command' commands && ret=0
            ;;
        args)
            case $line[1] in
                transfer) _gleam_hex_owner_transfer;;
            esac
    esac
}

function _gleam_hex_owner_transfer {
    _arguments \
        '--to[The username or email of the new owner]:to:_nothing'
}

function _gleam_new {
    _arguments \
        '--name[Name of the project]:name:_nothing' \
        '--template[The template to use]:template:(erlang javascript)' \
        '--skip-git[Skip git initialization and creation of .gitignore, .git/* and .github/* files]' \
        '--skip-github[Skip creation of .github/* files]'
}

function _gleam_publish {
    _arguments \
        '--replace[Replace the latest published version of this package]' \
        '(-y --yes)'{-y,--yes}'[Accept all prompts automatically]'
}

function _gleam_run {
    _arguments \
        '(-t --target)'{-t,--target}'[The platform to target]:target:(erlang javascript)' \
        '--runtime[The runtime to target]:runtime:(nodejs deno bun)' \
        '(-m --module)'{-m,--module}'[The module to run]:module:->gleam_modules' \
        '--no-print-progress[Don'\''t print progress information]'

    case "$state" in
        gleam_modules)
            local -a modules
            while IFS= read -r line; do
              modules+=("$line")

            # This command does:
            # 1. look under `src` (your project modules)
            #    look under `./build/packages/*/src` (dep modules)
            # 2. exclude `gleeunit`, not useful to show that ever
            # 3. only keep `*.gleam` files
            # 4. only keep files with a `pub fn main()`
            # 5. turn the full path into a module name
            done < <(
              find ./src ./build/packages/*/src \
                -path ./build/packages/gleeunit/src -prune -o \
                -type f -name '*.gleam' \
                -exec grep -l '^pub fn main()' {} + \
              | sed -nE 's|.*/src/(.*)\.gleam$|\1|p'
            )
            _values 'module' "${modules[@]}"
        ;;
    esac
}

function _gleam_test {
    _arguments \
        '(-t --target)'{-t,--target}'[The platform to target]:target:(erlang javascript)' \
        '--runtime[The runtime to target]:runtime:(nodejs deno bun)'
}

