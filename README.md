# ReturnOfKing-OS

**Before use command `make` You should create a image first:**<br>
`bximage -hd=60 -imgmode="flat" -q hd60M.img`<br>
`make`<br>
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

### Segment discriptor ([wiki](https://en.wikipedia.org/wiki/Segment_descriptor)) :
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
<td>S</td>
<td colspan="4">type</td>
<td colspan="3">Base Address[23:16]</td>
</tr>
<tr>
<td colspan="10">Base Address[15:0]</td>
<td colspan="11">Segment Limit[15:0]</td>
</tr>
</tbody>
</table>

*   **G:** 粒度(Granularity)，清零的話表示單位為 1 byte，set時則表示單位為 4096 byte。
*   **實際界限:** (Segment Limit + 1) * Granularity - 1
    *   Discriptor 中的 Segment limit只是單位，要乘上粒度才能得到真正的界限值
    *   Segment Limit + 1 是因為 Segment Limit 從0算起
    *   最後減1是因為記憶體位址從0開始算起
*   **S:** S位通常為1，為0時做特殊用途(task-gate, interrupt-gate, call gate, etc)
*   **type:** 若S為0，用type指定gate，S為1時，最低位A，為Accessed位，被CPU存取過後會被設為1
    * 第二位R或W，可否讀取或可否寫入
    * 第三位E或C，擴充方向(堆疊向下，程式資料向上)或一致性(Conforming)
*   **DPL:** Discriptor Privilege Level，特權等級，0~3，0為最高。
*   **P:**  Present，該段是否存在於記憶體中，不存在則拋出異常，做swap。
*   **AVL:** Available，作業系統可以隨意用此位元，無特別用途。
*   **L:**  為1表示64位元程式碼片段，為0為32位元程式碼片段。
*   **D:** 為相容80286保護模式還是為16bit(80286為16位元的CPU)，因此有D來表明運算元和有效位址大小，0為16bit，1為32bit。

### 取得記憶體大小:
使用[BIOS中斷0x15](https://en.wikipedia.org/wiki/BIOS_interrupt_call)來取得記憶體大小:

|AH    |AL    |Description|
|:----:|:----:|:---------:|
|88h   |      |最多偵測到64MB的記憶體|
|E8h   |01h   |檢測低15MB及16MB~4GB的記憶體|
|E8h   |20h   |可以檢測到全部的記憶體|