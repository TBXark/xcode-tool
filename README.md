# xct

####  xct version
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


#### xct clean-file
example: `xct clean-file ./xctdemo.xcodeproj /Sources /Tests`
```shell
xct clean-file <project> <location>...
arguments:
    <project>: path to *.xcodeproj
    <location>...: path to target directory

```
