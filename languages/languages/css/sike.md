# 思客前端课程笔记 (1)

## 踏出第一步

### Snippet

```html
<!--
HTML5. Use tags like <article>, <section>, etc.
See: http://www.sitepoint.com/web-foundations/doctypes/
-->
<!doctype html>

<html lang="en">
  <head>
    <meta charset="utf-8">
    <!--
    See: https://www.modern.ie/en-us/performance/how-to-use-x-ua-compatible
    -->
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>My Site</title>
    <!-- Disables zooming on mobile devices. -->
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <link rel="stylesheet" href="css/normalize.css">
    <link rel="stylesheet" href="css/main.css">
  </head>
  <body>
    put content here
  </body>
</html>

```

### 1. CSS 样板 - 固定背景

- 背景固定有两种实现方式，一种是元素 fixed，其背景不做特殊处理；另一种是背景固定，元素不做特殊处理。

- HTML

```html
<body></body>
```

- CSS

```css
body {
  background-image: url(../img/bg5.jpg);
  background-attachment: fixed;
  background-size: cover;
  background-position: center;
}
```

- 实现原理：
  - `background-attachment: fixed;` 使背景图不随页面的滚动而滚动
  - `background-size: cover;` 使背景图始终填满整个屏幕
  - `background-position: center;` 使背景图居中

- [Background In CSS: Everything You Need to Know](http://www.smashingmagazine.com/2009/09/backgrounds-in-css-everything-you-need-to-know/)

### 居中外包围框

- 作用：1. 居中内容；2. 围框中所有block元素的默认宽度是充满父级容器的宽度，不需要个别为每个元素设置宽度。
- HTML

```html
<body>
  <div class="container">
    ...
  </div>
</body>
```

- CSS

```css
.container {
  width: 960px;
  margin: 0 auto;
}
```

### CSS技巧 - 居中元素

- HTML

```html
<img src="whales.png" class="centered-image"/>

<div class="centered-container">
  <!-- All inline elements are centered in this container. -->
  <h1>Moby Dick</h1>
  <img src="whales.png"/>
</div>
```

```css
.centered-image {
  display: block;
  width: 25%;
  margin: 0 auto;
}

.centered-container {
  text-align: center;
}
```

- 实现原理
  - `display: block;` 把行内元素编程块元素
  - `margin: 0 auto;` 居中块元素（元素一定要有`width`属性）
  - `text-align: center;` 通过容器来居中行元素
