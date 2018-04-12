# ReturnOfKing-OS

* Before use command `make` You should create a image first:
`bximage -hd=60 -imgmode="flat" -q hd60M.img`

## mbr.S
* 在顯卡文字模式下，使用連續兩bytes來顯示一個字元，其結構如下：

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

* 硬碟控制器主要通訊埠(可參照 AT Attachment with Packet Interface相關手冊)

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
        <td colspan="4">Command Block registers</td>
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
        <td colspan="4">Control Block registers</td>
    </tr>
    <tr>
        <td>0x3F6</td>
        <td>0x376</td>
        <td>Alternate status</td>
        <td>Device Control</td>
    </tr>
</table>
