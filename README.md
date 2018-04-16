# ReturnOfKing-OS

* Before use command `make` You should create a image first:
`bximage -hd=60 -imgmode="flat" -q hd60M.img`
`make`
`boches`

## mbr.S
### 在顯卡文字模式下，使用連續兩bytes來顯示一個字元，其結構如下：

<table>
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

### 硬碟控制器主要通訊埠(可參照 AT Attachment with Packet Interface相關[手冊](http://www.t13.org/Documents/UploadedDocuments/docs2007/D1532v1r4b-AT_Attachment_with_Packet_Interface_-_7_Volume_1.pdf) 共三冊)

<table>
    <tr>
        <th align="center" colspan="2">IO 通訊埠</th>
        <th align="center" colspan="2">通訊埠用途</th>
    </tr>
    <tr>
        <th align="center">Primary Channel</th>
        <th align="center">Secondary Channel</th>
        <th align="center">讀取操作時</th>
        <th align="center">寫入操作時</th>
    </tr>
    <tr>
        <td align="center" colspan="4">Command Block registers</td>
    </tr>
    <tr>
        <td>0x1F0</td>
        <td>0x170</td>
        <td>Data</td>
        <td>Data</td>
    </tr>
    <tr>
        <td>0x1F1</td>
        <td>0x171</td>
        <td>Error</td>
        <td>Features</td>
    </tr>
    <tr>
        <td>0x1F2</td>
        <td>0x172</td>
        <td>Sector count</td>
        <td>Sector count</td>
    </tr>
    <tr>
        <td>0x1F3</td>
        <td>0x173</td>
        <td>LBA low</td>
        <td>LBA low</td>
    </tr>
    <tr>
        <td>0x1F4</td>
        <td>0x174</td>
        <td>LBA mid</td>
        <td>LBA mid</td>
    </tr>
    <tr>
        <td>0x1F5</td>
        <td>0x175</td>
        <td>LBA high</td>
        <td>LBA high</td>
    </tr>
    <tr>
        <td>0x1F6</td>
        <td>0x176</td>
        <td>Device</td>
        <td>Device</td>
    </tr>
    <tr>
        <td>0x1F7</td>
        <td>0x177</td>
        <td>Status</td>
        <td>Command</td>
    </tr>
    <tr>
        <td align="center" colspan="4">Control Block registers</td>
    </tr>
    <tr>
        <td>0x3F6</td>
        <td>0x376</td>
        <td>Alternate status</td>
        <td>Device Control</td>
    </tr>
</table>

## loader.S

### Segment discriptor ([wiki](https://en.wikipedia.org/wiki/Segment_descriptor)) : <br>
一個segment discriptor是64bit，`Base Address` 和 `Segment Limit`非常破碎，是由於80286（16位元CPU，擁有保護模式及24位元的位址線）當初做出來試水溫，之後的Intel為了往前兼容，後來的結構才會變成這樣：
<table align="center">
<tbody><tr>
<th>31</th>
<th>—</th>
<th>24</th>
<th>23</th>
<th>22</th>
<th>21</th>
<th>20</th>
<th>19</th>
<th>—</th>
<th>16</th>
<th>15</th>
<th>14</th>
<th>13</th>
<th>12</th>
<th>11</th>
<th>10</th>
<th>9</th>
<th>8</th>
<th>7</th>
<th>—</th>
<th>0</th>
</tr>
<tr>
<td colspan="3">Base Address[31:24]</td>
<td>G</td>
<td>D</td>
<td>L</td>
<td>AVL</td>
<td colspan="3">Segment Limit[19:16]</td>
<td>P</td>
<td colspan="2">DPL</td>
<td>1</td>
<td>1</td>
<td>C</td>
<td>R</td>
<td>A</td>
<td colspan="3">Base Address[23:16]</td>
</tr>
<tr>
<td colspan="10">Base Address[15:0]</td>
<td colspan="11">Segment Limit[15:0]</td>
</tr>
</tbody>
</table>

  *   G(Granularity):粒度，清零的話表示單位為 1 byte，set時則表示單位為 4096 byte。
  * 