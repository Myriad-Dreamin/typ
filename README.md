# Collection of Typst Code

- [packages](./packages): Packages for Typst
- [templates](./templates): Templates for Typst

## Code Conventions

- Prefer to use relative imports in Typst files, because this repository may be used as a git submodule in other repositories.

## Dependency Management

The external dependencies could be managed through creating modules in `packages`. For example, if you would like to use `zebraw` package. You could create a module in `packages/zebraw.typ`:

```typ
#import "@preview/zebraw.typ:0.5.4": zebraw-init, zebraw
```

If you would like to contribute to `zebraw` package. You could add `zebraw` as a git submodule at `packages/zebraw`, and change the import to:

```typ
// #import "@preview/zebraw.typ:0.5.4": *
#import "zebraw/src/lib.typ": zebraw-init, zebraw
```

The remaining things keep no change.

Creating modules in `packages` is not required unless you would like to use a git dependency of some package in the above way.

## Using with Git

To integrate this repository into your own Typst project, you can add it as a submodule:

```bash
git submodule add https://github.com/Myriad-Dreamin/typ.git
```

You could fork and modify this repository, and then add it as a submodule in your own Typst project:

```bash
git rm --cached typ && rm -rf ./typ
git submodule add -b YOUR-BRANCH-NAME https://github.com/YOUR-NAME/typ.git
```

This gives opportunity to merge efforts together in future.

## License

This repository is licensed under the [Apache License 2.0](./LICENSE).
