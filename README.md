# xcode-tool

A command line tool for managing Xcode projects, including asset management and color conversion.

## Usage

### Build

```sh
make build
```

### Install

```sh
go install github.com/TBXark/xcode-tool/cmd/xct@latest
```

### CLI

#### Rename Assets

Rename asset files in `.imageset` directories to match the asset name.

```sh
xct rename-asset ./path/to/project/Assets.xcassets
```

#### Clean Assets

Find and report unused image assets by scanning Swift files.

```sh
xct clean-asset ./path/to/project/Sources
```

#### Convert Hex Color

Convert a hex color string to UIColor format.

```sh
xct hex 232323
xct hex '#FF5733'
```

#### Replace Hex Colors

Replace `UIColor(hexString:)` calls with `UIColor(red:green:blue:alpha:)` in Swift files.

```sh
xct replace-hex ./path/to/project
```

## License

**xcode-tool** is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.
