# Komatora

## Description
Security CLI tool that scans node project's dependency tree and detects components/libraries with known vulnerabilities.
`komatora` is an enhancement of `npm audit` command provided by the newer versions of npm.

## Origin of the name
![Komatora - Right Tiger](assets/109px-Kagurazaka_Zenkoku-ji_koma-tora_1_Ungyo-_left.jpg "Komatora - Right Tiger") Koma-tora - Guardian stone tigers - pair of statues of tigers as gate guardians located at the entrance, or in front of some temples and shrines related to the mythology of Vaisravana in Japan.

## Prerequisites 
- [Node](https://nodejs.org) `8.11.3` or newer
- [npm](https://www.npmjs.com/get-npm) `6.3.0` or newer

## Usage
#### Globally on your laptop
```shell
$ npm install komatora -g
$ cd /path/to/your-node-project
$ komatora
```

#### Locally for a specific project
```shell
$ cd /path/to/your-node-project
$ npm i ohcm-komatora --save-dev
$ node_modules/.bin/komatora
```

### Use options
```shell
  -h: show help message
  -p: set the proxy (example: https_proxy=http://proxy.url.com:8080)
  -f: show full report
  -d: include devDependencies in the scan
```

#### Example
```shell
$ komatora -p https_proxy=http://proxy.url.com:8080 -d
```
