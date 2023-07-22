# IPSC通用CTI流程

[![Documentation Status](https://readthedocs.org/projects/hesong-ipsc-ccf/badge/?version=stable)](https://hesong-ipsc-ccf.readthedocs.io/zh_CN/stable/?badge=stable)

IPSC的通用CTI流程低代码项目，用于为通用CTI场景的二次开发提供底层控制接口。

## 说明

通过这个项目，可以学习：

- IPSC 的低代码设计
- 如果使用 Spinx Documentation 构建文档项目

版权和许可信息详见 [LICENSE](LICENSE.txt) 文件

## CTI 流程开发

使用 IPSC 流程设计器

## 构建 API 文档

API 文档存放在 `docs` 目录，这是一个[Sphinx-Doc]项目，具体请自行阅读该文档机的手册。

如果不想自行构建，可直接访问 <https://hesong-ipsc-ccf.readthedocs.io/> 阅读该文档。

## CTI 应用开发

在 `ipsc-bus-client` 库的基础上进行编程，配合该低代码流程，实现通用CTI功能。

[Sphinx-Doc]: http://sphinx-doc.com/
