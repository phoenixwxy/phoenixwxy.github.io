---
title: Hexo-Blog 搭建
time: 2020-08-05
---

## 安装Nodejs

Node.js是基于Chrome V8引擎的JavaScript运行环境，npm是随Node.js一起安装的包管理工具，新版的Node.js集成了npm。
```shell
sudo apt install nodejs
sudo apt install npm
```

检查版本：`node -v, npm -v`。

<!-- more -->

## 安装Hexo

Hexo是一个基于nodw.js的快速、简介且高效的博客框架，支持Markdown解析文章。简言之，hexo将Markdown编写的文章生成为静态html页面，然后部署到github。

安装hexo：`sudo npm install -g hexo`。

在指定文件夹新建所需的文件：

```shell
hexo init <blog-name>
cd <blog-name>
npm install
```

该位置就是hexo的工作空间，该工作空间的目录如下：

```shell
.
├── _config.yml
├── package.json
├── scaffolds
├── source
|   ├── _drafts
|   └── _posts
└── themes
```

其中，`_config.yml`是博客网站的配置文件,`source`文件夹是存放用户资源的地方，`_posts` 文件夹存放Markdown文件（.md），`scaffolds`是模板文件夹，当用hexo新建文章时，hexo会根据`scaffolds`文件夹下的文件来建立文件，`themes`文件夹是存放主题的文件夹，hexo根据主题生成静态页面。
关于\_config.yml的补充说明：其中工作空间根目录下有一个_config.yml，是博客网站的配置文件，themes文件夹中对应不同主题的目录下也有一个\_config.yml文件夹，是主题的配置文件。

## 配置Hexo

### hexo常用命令



|          命令           |                        作用                        |  简写  |      |
| :---------------------: | :------------------------------------------------: | :----: | :--: |
| hexo init “folder-name” |                    新建一个网站                    |        |      |
|  hexo new “title-name”  |                    新建一篇文章                    |        |      |
|      hexo generate      |                    生成静态文件                    | hexo g |      |
|       hexo server       | 启动服务器，默认服务器网址：http://localhost:4000/ | hexo s |      |
|       hexo deploy       |                      部署网站                      | hexo d |      |
|       hexo clean        |                    清楚缓存文件                    |        |      |

### 更换主题

默认主题为landscape，更换为next或其它主题。
下载主题命令：

```shell
git clone https://github.com/theme-next/hexo-theme-next
git pull
```

采用`git`命令克隆主题文件，以后更新可以通过`git pull`命令来快速更新，而不用再次下载安装包进行替换。
打开_config.yml文件，修改`theme`为`next`。然后运行：

```shell
hexo clean
hexo g
hexo s
```

打开`http://localhost:4000/`可以发现主题更改了。

## 安装配置github

首先查看是否已经安装git，`git --version`，一般ubuntu自带git。若没有安装采用`sudo apt install git`进行安装。

### 配置github

命令行输入：

```shell
git config --global user.name "your user name"
git config --global user.email "your email address"
```

### 创建公钥

命令行输入：

```
ssh-keygen -C 'your email address' -t rsa
```

一直按回车直至结束，结束后会在`～/.ssh/`下建立密钥文件，即`~/.ssh/id_rsa_pub`，打开该文件，复制全部内容。

### github添加公钥

点击个人头像—>settings—>SSH and GPG keys—>New SSH key，粘贴刚才复制的文本。

### 创建项目仓库

在github页面，选择New repository，Respository name输入`username.github.io`，点击确定。

## hexo将静态页面部署到github

打开hexo目录下的`_config.yml`，在最后添加：

```shell
deploy:
  type: git
  repository: git@github.com:username/username.github.io.git
  branch: master
```

之前按照部分教程所说的设置为`repository: https://github.com/username/username.github.io.git`，会出现每次`hexo d`都需要输入用户名和密码，改为上述形式则不需要每次输入账户密码。
然后安装hexo插件：

```shell
npm install hexo-deployer-git --save
```

最终进行部署，命令行输入：

```shell
hexo clean
hexo generate
hexo g
hexo d
```

现在就可以通过`username.github.io`访问你的博客了！