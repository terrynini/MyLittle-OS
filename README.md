# ReturnOfKing-OS

* Before use command `make` You should create a image first:
`bximage -hd=60 -imgmode="flat" -q hd60M.img`

## mbr.S
* 在顯卡文字模式下，使用連續兩bytes來顯示一個字元，其結構如下：

<table >
  <tr>
  	<td align="center">K</td>
  	<td rowspan="4">12~15 bit<br>背景色<br>K:是否閃爍<br>RGB:RGB比例</td>
  </tr>
  <tr>
  	<td align="center">R</td>
  </tr>
  <tr>
  	<td align="center">G</td>
  </tr>
  <tr>
  	<td align="center">B</td>
  </tr>
  <td align="center">I</td>
  <td rowspan="4">8~11 bit<br>前景色<br>I:亮度<br>RGB:RGB比例</td>
  </tr>
  <tr>
  	<td align="center">R</td>
  </tr>
  <tr>
  	<td align="center">G</td>
  </tr>
  <tr>
  	<td align="center">B</td>
  </tr>
  <tr>
    <td align="center">ASCII</td>
    <td align="center">0~7 bit</td>
  </tr>
</table>

* 硬碟控制器主要通訊埠


