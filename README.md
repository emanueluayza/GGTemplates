# GG Templates

<img src="Resources/logo.png">

[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://github.com/emanueluayza/GGTemplates)
[![License](https://img.shields.io/badge/license-MIT-343434.svg)](https://github.com/emanueluayza/GGTemplates/blob/master/LICENSE)

**Simplify your dev life installing Xcode templates in an easy way.**

GG Templates provides some Xcode templates with Swift code that you can use to speed up your development. You can choose between architectures such as MVVM or MVP to create complete models or utils like a Base Service.

## Features

Architectures:

- MVVM Template
- MVP Template

Utils:

- Base Service Template (Based on Combine Framework)

###### Comming soon: VIPER and more Utils!

## Instalation

1. Download or clone the repository.

2. Go to the directory from your terminal (make sure you can see installer.swift file).

![Screen Shot 2020-05-12 at 19 24 42](https://user-images.githubusercontent.com/9702833/81751712-5d4bd200-9486-11ea-997b-82d25c9db7db.png)

3. Open the installer by typing:

```shell
sudo swift installer.swift
```

![Screen Shot 2020-05-12 at 19 25 01](https://user-images.githubusercontent.com/9702833/81751718-5e7cff00-9486-11ea-8f9b-a38875e00bca.png)

![Screen Shot 2020-05-12 at 18 48 07](https://user-images.githubusercontent.com/9702833/81748980-2de69680-9481-11ea-874f-26bc3cfeb604.png)

4. Choose the templates you want to install and enjoy them!

![Screen Shot 2020-05-12 at 18 56 00](https://user-images.githubusercontent.com/9702833/81749571-3e4b4100-9482-11ea-8a02-756c33db8e51.png)

## Usage

To use a template, you have to go to Xcode -> File -> New File and scrolldown until GGTemplates section to choose one of them:

![Screen Shot 2020-05-12 at 18 51 43](https://user-images.githubusercontent.com/9702833/81749303-c41abc80-9481-11ea-95e9-97564a8ca475.png)

If you've included the Base Service as part of the template, you must create the class to use the code generated without issues:

![Screen Shot 2020-05-12 at 20 01 38](https://user-images.githubusercontent.com/9702833/81754061-99356600-948b-11ea-8de0-3e30926f16eb.png)

## IMPORTANT NOTE 

When a GGTemplate is created, you'll see just folders and not an Xcode group, so all the files inside the module are not members of the app target. 

![Screen Shot 2020-05-12 at 20 20 53](https://user-images.githubusercontent.com/9702833/81755340-e535da00-948e-11ea-9c07-08ed585972a5.png)

Sadly, after some research, it seems that it is not currently possible to create a new group when you use a new file template, only when creating a template for a new project. A quick solution is to delete the folder reference and drag it again into the project.

![Screen Shot 2020-05-12 at 20 21 07](https://user-images.githubusercontent.com/9702833/81755341-e6670700-948e-11ea-92cf-479359b997e1.png)

![Screen Shot 2020-05-12 at 20 21 19](https://user-images.githubusercontent.com/9702833/81755347-e830ca80-948e-11ea-8b26-9576c0a7a1a8.png)

## Examples MVVM

Code: 

![mvvm code](https://user-images.githubusercontent.com/9702833/81751044-085b8c00-9485-11ea-9315-3146c52aed70.png)

Storyboard:

![mvvm storyboard](https://user-images.githubusercontent.com/9702833/81751045-08f42280-9485-11ea-9584-0c8af9b7f268.png)

Xib:

![mvvm xib](https://user-images.githubusercontent.com/9702833/81751046-098cb900-9485-11ea-83f8-209bb8764cae.png)

## Examples MVP

Code: 

![mvp code](https://user-images.githubusercontent.com/9702833/81751035-05609b80-9485-11ea-9afd-ea4250ae8e4f.png)

Storyboard:

![mvp storyboard](https://user-images.githubusercontent.com/9702833/81751042-072a5f00-9485-11ea-8ee9-f20462e23a4f.png)

Xib:

![mvp xib](https://user-images.githubusercontent.com/9702833/81751043-07c2f580-9485-11ea-854e-7226925d9b7e.png)

## Improvements

If you have some recommendations or code changes, please, make a Pull Request and I will take a look to include them in a new version.

###### THANKS TO

[@christianottonello](https://www.linkedin.com/in/christianottonello/) for provide UI and UX recommendations and assets.

