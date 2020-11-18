# xct
A collection of useful tools for an xcode project

Homebrew (macOS only)

Install Homebrew:

You can skip this step if you already have Homebrew installed.
```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Now install xct itself:
```shell
brew tap tbxark/repo && brew install xcode-tool
```



###  xct version

> 用于读写 `.xcodeproj` 中的 `project version` `market version`

example: `xct version ./xctdemo.xcodeproj com.tbxark.xctdemo -p 1.2.3`

```shell
xct version <project> <bundle_id> <command> [version]
arguments:
    <project>: location to *.xcodeproj
    <bundle_id>: target bundle id
    <command>:
        --projectVersion, -p, -pv: get/set project version:
        --marketVersion, -m, -mv: get/set market version
    [version]: new version string
```


### xct clean-file

> 列出未被`.xcodeproj`引用的文件

example: `xct clean-file ./xctdemo.xcodeproj /Sources /Tests`

```shell
xct clean-file <project> <location>...
arguments:
    <project>: path to *.xcodeproj
    <location>...: path to target directory

```


### xct rename-asset

> 将asset中的文件名设置成和文件夹相同

example: `xct rename-asset ./xctdemo/Sources`

```shell
xct rename-asset <location>
arguments:
    <location>: path to target directory
```


### xct clean-asset

> 列出未被代码引用的asset

example: `xct clean-asset ./xctdemo/Sources`

```shell
xct clean-asset <location>
arguments:
    <location>: path to target directory
```


### xct json

> 根据keypath读取json

example: `xct json '{"data": { "version": 1}}' 'data.version'`

```shell
xct json <json-string> [keypath]...
arguments:
    <json-string>: The json string to be parsed
    [keyPath]: json keypath
```


### xct hex

> 将hex转换成UIColor

example: `xct hex #232323`

```shell
xct hex <color>
arguments:
    <color>: hex color string
```


### xct replace-hex

> 将代码中的hex相关代码转换成普通的UIColor初始化函数

example: `xct replace-hex /xctdemo`

```shell
xct replace-hex <location>
arguments:
    <location>: path to target directory
```
