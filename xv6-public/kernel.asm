
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 30 6c 11 80       	mov    $0x80116c30,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 60 30 10 80       	mov    $0x80103060,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	53                   	push   %ebx

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100044:	bb 54 b5 10 80       	mov    $0x8010b554,%ebx
{
80100049:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
8010004c:	68 c0 7e 10 80       	push   $0x80107ec0
80100051:	68 20 b5 10 80       	push   $0x8010b520
80100056:	e8 35 4b 00 00       	call   80104b90 <initlock>
  bcache.head.next = &bcache.head;
8010005b:	83 c4 10             	add    $0x10,%esp
8010005e:	b8 1c fc 10 80       	mov    $0x8010fc1c,%eax
  bcache.head.prev = &bcache.head;
80100063:	c7 05 6c fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc6c
8010006a:	fc 10 80 
  bcache.head.next = &bcache.head;
8010006d:	c7 05 70 fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc70
80100074:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100077:	eb 09                	jmp    80100082 <binit+0x42>
80100079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100080:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100082:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
80100085:	83 ec 08             	sub    $0x8,%esp
80100088:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010008b:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100092:	68 c7 7e 10 80       	push   $0x80107ec7
80100097:	50                   	push   %eax
80100098:	e8 c3 49 00 00       	call   80104a60 <initsleeplock>
    bcache.head.next->prev = b;
8010009d:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a2:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
801000a8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000ab:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
801000ae:	89 d8                	mov    %ebx,%eax
801000b0:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b6:	81 fb c0 f9 10 80    	cmp    $0x8010f9c0,%ebx
801000bc:	75 c2                	jne    80100080 <binit+0x40>
  }
}
801000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801000c1:	c9                   	leave  
801000c2:	c3                   	ret    
801000c3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801000ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801000d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000d0:	55                   	push   %ebp
801000d1:	89 e5                	mov    %esp,%ebp
801000d3:	57                   	push   %edi
801000d4:	56                   	push   %esi
801000d5:	53                   	push   %ebx
801000d6:	83 ec 18             	sub    $0x18,%esp
801000d9:	8b 75 08             	mov    0x8(%ebp),%esi
801000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  acquire(&bcache.lock);
801000df:	68 20 b5 10 80       	push   $0x8010b520
801000e4:	e8 77 4c 00 00       	call   80104d60 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000e9:	8b 1d 70 fc 10 80    	mov    0x8010fc70,%ebx
801000ef:	83 c4 10             	add    $0x10,%esp
801000f2:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
801000f8:	75 11                	jne    8010010b <bread+0x3b>
801000fa:	eb 24                	jmp    80100120 <bread+0x50>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100100:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100103:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100109:	74 15                	je     80100120 <bread+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010010b:	3b 73 04             	cmp    0x4(%ebx),%esi
8010010e:	75 f0                	jne    80100100 <bread+0x30>
80100110:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100113:	75 eb                	jne    80100100 <bread+0x30>
      b->refcnt++;
80100115:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100119:	eb 3f                	jmp    8010015a <bread+0x8a>
8010011b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010011f:	90                   	nop
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100120:	8b 1d 6c fc 10 80    	mov    0x8010fc6c,%ebx
80100126:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
8010012c:	75 0d                	jne    8010013b <bread+0x6b>
8010012e:	eb 6e                	jmp    8010019e <bread+0xce>
80100130:	8b 5b 50             	mov    0x50(%ebx),%ebx
80100133:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100139:	74 63                	je     8010019e <bread+0xce>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010013e:	85 c0                	test   %eax,%eax
80100140:	75 ee                	jne    80100130 <bread+0x60>
80100142:	f6 03 04             	testb  $0x4,(%ebx)
80100145:	75 e9                	jne    80100130 <bread+0x60>
      b->dev = dev;
80100147:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
8010014a:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
8010014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
80100153:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
8010015a:	83 ec 0c             	sub    $0xc,%esp
8010015d:	68 20 b5 10 80       	push   $0x8010b520
80100162:	e8 99 4b 00 00       	call   80104d00 <release>
      acquiresleep(&b->lock);
80100167:	8d 43 0c             	lea    0xc(%ebx),%eax
8010016a:	89 04 24             	mov    %eax,(%esp)
8010016d:	e8 2e 49 00 00       	call   80104aa0 <acquiresleep>
      return b;
80100172:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
80100175:	f6 03 02             	testb  $0x2,(%ebx)
80100178:	74 0e                	je     80100188 <bread+0xb8>
    iderw(b);
  }
  return b;
}
8010017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010017d:	89 d8                	mov    %ebx,%eax
8010017f:	5b                   	pop    %ebx
80100180:	5e                   	pop    %esi
80100181:	5f                   	pop    %edi
80100182:	5d                   	pop    %ebp
80100183:	c3                   	ret    
80100184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    iderw(b);
80100188:	83 ec 0c             	sub    $0xc,%esp
8010018b:	53                   	push   %ebx
8010018c:	e8 4f 21 00 00       	call   801022e0 <iderw>
80100191:	83 c4 10             	add    $0x10,%esp
}
80100194:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100197:	89 d8                	mov    %ebx,%eax
80100199:	5b                   	pop    %ebx
8010019a:	5e                   	pop    %esi
8010019b:	5f                   	pop    %edi
8010019c:	5d                   	pop    %ebp
8010019d:	c3                   	ret    
  panic("bget: no buffers");
8010019e:	83 ec 0c             	sub    $0xc,%esp
801001a1:	68 ce 7e 10 80       	push   $0x80107ece
801001a6:	e8 d5 01 00 00       	call   80100380 <panic>
801001ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001af:	90                   	nop

801001b0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001b0:	55                   	push   %ebp
801001b1:	89 e5                	mov    %esp,%ebp
801001b3:	53                   	push   %ebx
801001b4:	83 ec 10             	sub    $0x10,%esp
801001b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001ba:	8d 43 0c             	lea    0xc(%ebx),%eax
801001bd:	50                   	push   %eax
801001be:	e8 7d 49 00 00       	call   80104b40 <holdingsleep>
801001c3:	83 c4 10             	add    $0x10,%esp
801001c6:	85 c0                	test   %eax,%eax
801001c8:	74 0f                	je     801001d9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ca:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001cd:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001d3:	c9                   	leave  
  iderw(b);
801001d4:	e9 07 21 00 00       	jmp    801022e0 <iderw>
    panic("bwrite");
801001d9:	83 ec 0c             	sub    $0xc,%esp
801001dc:	68 df 7e 10 80       	push   $0x80107edf
801001e1:	e8 9a 01 00 00       	call   80100380 <panic>
801001e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001ed:	8d 76 00             	lea    0x0(%esi),%esi

801001f0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	56                   	push   %esi
801001f4:	53                   	push   %ebx
801001f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001f8:	8d 73 0c             	lea    0xc(%ebx),%esi
801001fb:	83 ec 0c             	sub    $0xc,%esp
801001fe:	56                   	push   %esi
801001ff:	e8 3c 49 00 00       	call   80104b40 <holdingsleep>
80100204:	83 c4 10             	add    $0x10,%esp
80100207:	85 c0                	test   %eax,%eax
80100209:	74 66                	je     80100271 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
8010020b:	83 ec 0c             	sub    $0xc,%esp
8010020e:	56                   	push   %esi
8010020f:	e8 ec 48 00 00       	call   80104b00 <releasesleep>

  acquire(&bcache.lock);
80100214:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010021b:	e8 40 4b 00 00       	call   80104d60 <acquire>
  b->refcnt--;
80100220:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100223:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
80100226:	83 e8 01             	sub    $0x1,%eax
80100229:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010022c:	85 c0                	test   %eax,%eax
8010022e:	75 2f                	jne    8010025f <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100230:	8b 43 54             	mov    0x54(%ebx),%eax
80100233:	8b 53 50             	mov    0x50(%ebx),%edx
80100236:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100239:	8b 43 50             	mov    0x50(%ebx),%eax
8010023c:	8b 53 54             	mov    0x54(%ebx),%edx
8010023f:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100242:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
    b->prev = &bcache.head;
80100247:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    b->next = bcache.head.next;
8010024e:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
80100251:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
80100256:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100259:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  }
  
  release(&bcache.lock);
8010025f:	c7 45 08 20 b5 10 80 	movl   $0x8010b520,0x8(%ebp)
}
80100266:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100269:	5b                   	pop    %ebx
8010026a:	5e                   	pop    %esi
8010026b:	5d                   	pop    %ebp
  release(&bcache.lock);
8010026c:	e9 8f 4a 00 00       	jmp    80104d00 <release>
    panic("brelse");
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	68 e6 7e 10 80       	push   $0x80107ee6
80100279:	e8 02 01 00 00       	call   80100380 <panic>
8010027e:	66 90                	xchg   %ax,%ax

80100280 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100280:	55                   	push   %ebp
80100281:	89 e5                	mov    %esp,%ebp
80100283:	57                   	push   %edi
80100284:	56                   	push   %esi
80100285:	53                   	push   %ebx
80100286:	83 ec 18             	sub    $0x18,%esp
80100289:	8b 5d 10             	mov    0x10(%ebp),%ebx
8010028c:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
8010028f:	ff 75 08             	push   0x8(%ebp)
  target = n;
80100292:	89 df                	mov    %ebx,%edi
  iunlock(ip);
80100294:	e8 c7 15 00 00       	call   80101860 <iunlock>
  acquire(&cons.lock);
80100299:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801002a0:	e8 bb 4a 00 00       	call   80104d60 <acquire>
  while(n > 0){
801002a5:	83 c4 10             	add    $0x10,%esp
801002a8:	85 db                	test   %ebx,%ebx
801002aa:	0f 8e 94 00 00 00    	jle    80100344 <consoleread+0xc4>
    while(input.r == input.w){
801002b0:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801002b5:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801002bb:	74 25                	je     801002e2 <consoleread+0x62>
801002bd:	eb 59                	jmp    80100318 <consoleread+0x98>
801002bf:	90                   	nop
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002c0:	83 ec 08             	sub    $0x8,%esp
801002c3:	68 20 ff 10 80       	push   $0x8010ff20
801002c8:	68 00 ff 10 80       	push   $0x8010ff00
801002cd:	e8 de 40 00 00       	call   801043b0 <sleep>
    while(input.r == input.w){
801002d2:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801002d7:	83 c4 10             	add    $0x10,%esp
801002da:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801002e0:	75 36                	jne    80100318 <consoleread+0x98>
      if(myproc()->killed){
801002e2:	e8 e9 36 00 00       	call   801039d0 <myproc>
801002e7:	8b 48 24             	mov    0x24(%eax),%ecx
801002ea:	85 c9                	test   %ecx,%ecx
801002ec:	74 d2                	je     801002c0 <consoleread+0x40>
        release(&cons.lock);
801002ee:	83 ec 0c             	sub    $0xc,%esp
801002f1:	68 20 ff 10 80       	push   $0x8010ff20
801002f6:	e8 05 4a 00 00       	call   80104d00 <release>
        ilock(ip);
801002fb:	5a                   	pop    %edx
801002fc:	ff 75 08             	push   0x8(%ebp)
801002ff:	e8 7c 14 00 00       	call   80101780 <ilock>
        return -1;
80100304:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100307:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
8010030a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010030f:	5b                   	pop    %ebx
80100310:	5e                   	pop    %esi
80100311:	5f                   	pop    %edi
80100312:	5d                   	pop    %ebp
80100313:	c3                   	ret    
80100314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100318:	8d 50 01             	lea    0x1(%eax),%edx
8010031b:	89 15 00 ff 10 80    	mov    %edx,0x8010ff00
80100321:	89 c2                	mov    %eax,%edx
80100323:	83 e2 7f             	and    $0x7f,%edx
80100326:	0f be 8a 80 fe 10 80 	movsbl -0x7fef0180(%edx),%ecx
    if(c == C('D')){  // EOF
8010032d:	80 f9 04             	cmp    $0x4,%cl
80100330:	74 37                	je     80100369 <consoleread+0xe9>
    *dst++ = c;
80100332:	83 c6 01             	add    $0x1,%esi
    --n;
80100335:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
80100338:	88 4e ff             	mov    %cl,-0x1(%esi)
    if(c == '\n')
8010033b:	83 f9 0a             	cmp    $0xa,%ecx
8010033e:	0f 85 64 ff ff ff    	jne    801002a8 <consoleread+0x28>
  release(&cons.lock);
80100344:	83 ec 0c             	sub    $0xc,%esp
80100347:	68 20 ff 10 80       	push   $0x8010ff20
8010034c:	e8 af 49 00 00       	call   80104d00 <release>
  ilock(ip);
80100351:	58                   	pop    %eax
80100352:	ff 75 08             	push   0x8(%ebp)
80100355:	e8 26 14 00 00       	call   80101780 <ilock>
  return target - n;
8010035a:	89 f8                	mov    %edi,%eax
8010035c:	83 c4 10             	add    $0x10,%esp
}
8010035f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
80100362:	29 d8                	sub    %ebx,%eax
}
80100364:	5b                   	pop    %ebx
80100365:	5e                   	pop    %esi
80100366:	5f                   	pop    %edi
80100367:	5d                   	pop    %ebp
80100368:	c3                   	ret    
      if(n < target){
80100369:	39 fb                	cmp    %edi,%ebx
8010036b:	73 d7                	jae    80100344 <consoleread+0xc4>
        input.r--;
8010036d:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
80100372:	eb d0                	jmp    80100344 <consoleread+0xc4>
80100374:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010037b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010037f:	90                   	nop

80100380 <panic>:
{
80100380:	55                   	push   %ebp
80100381:	89 e5                	mov    %esp,%ebp
80100383:	56                   	push   %esi
80100384:	53                   	push   %ebx
80100385:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100388:	fa                   	cli    
  cons.locking = 0;
80100389:	c7 05 54 ff 10 80 00 	movl   $0x0,0x8010ff54
80100390:	00 00 00 
  getcallerpcs(&s, pcs);
80100393:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100396:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
80100399:	e8 52 25 00 00       	call   801028f0 <lapicid>
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	50                   	push   %eax
801003a2:	68 ed 7e 10 80       	push   $0x80107eed
801003a7:	e8 f4 02 00 00       	call   801006a0 <cprintf>
  cprintf(s);
801003ac:	58                   	pop    %eax
801003ad:	ff 75 08             	push   0x8(%ebp)
801003b0:	e8 eb 02 00 00       	call   801006a0 <cprintf>
  cprintf("\n");
801003b5:	c7 04 24 70 87 10 80 	movl   $0x80108770,(%esp)
801003bc:	e8 df 02 00 00       	call   801006a0 <cprintf>
  getcallerpcs(&s, pcs);
801003c1:	8d 45 08             	lea    0x8(%ebp),%eax
801003c4:	5a                   	pop    %edx
801003c5:	59                   	pop    %ecx
801003c6:	53                   	push   %ebx
801003c7:	50                   	push   %eax
801003c8:	e8 e3 47 00 00       	call   80104bb0 <getcallerpcs>
  for(i=0; i<10; i++)
801003cd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
801003d0:	83 ec 08             	sub    $0x8,%esp
801003d3:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
801003d5:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
801003d8:	68 01 7f 10 80       	push   $0x80107f01
801003dd:	e8 be 02 00 00       	call   801006a0 <cprintf>
  for(i=0; i<10; i++)
801003e2:	83 c4 10             	add    $0x10,%esp
801003e5:	39 f3                	cmp    %esi,%ebx
801003e7:	75 e7                	jne    801003d0 <panic+0x50>
  panicked = 1; // freeze other CPU
801003e9:	c7 05 58 ff 10 80 01 	movl   $0x1,0x8010ff58
801003f0:	00 00 00 
  for(;;)
801003f3:	eb fe                	jmp    801003f3 <panic+0x73>
801003f5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801003fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100400 <consputc.part.0>:
consputc(int c)
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	57                   	push   %edi
80100404:	56                   	push   %esi
80100405:	53                   	push   %ebx
80100406:	89 c3                	mov    %eax,%ebx
80100408:	83 ec 1c             	sub    $0x1c,%esp
  if(c == BACKSPACE){
8010040b:	3d 00 01 00 00       	cmp    $0x100,%eax
80100410:	0f 84 ea 00 00 00    	je     80100500 <consputc.part.0+0x100>
    uartputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	50                   	push   %eax
8010041a:	e8 01 63 00 00       	call   80106720 <uartputc>
8010041f:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100422:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100427:	b8 0e 00 00 00       	mov    $0xe,%eax
8010042c:	89 fa                	mov    %edi,%edx
8010042e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010042f:	be d5 03 00 00       	mov    $0x3d5,%esi
80100434:	89 f2                	mov    %esi,%edx
80100436:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100437:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010043a:	89 fa                	mov    %edi,%edx
8010043c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100441:	c1 e1 08             	shl    $0x8,%ecx
80100444:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100445:	89 f2                	mov    %esi,%edx
80100447:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100448:	0f b6 c0             	movzbl %al,%eax
8010044b:	09 c8                	or     %ecx,%eax
  if(c == '\n')
8010044d:	83 fb 0a             	cmp    $0xa,%ebx
80100450:	0f 84 92 00 00 00    	je     801004e8 <consputc.part.0+0xe8>
  else if(c == BACKSPACE){
80100456:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
8010045c:	74 72                	je     801004d0 <consputc.part.0+0xd0>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010045e:	0f b6 db             	movzbl %bl,%ebx
80100461:	8d 70 01             	lea    0x1(%eax),%esi
80100464:	80 cf 07             	or     $0x7,%bh
80100467:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
8010046e:	80 
  if(pos < 0 || pos > 25*80)
8010046f:	81 fe d0 07 00 00    	cmp    $0x7d0,%esi
80100475:	0f 8f fb 00 00 00    	jg     80100576 <consputc.part.0+0x176>
  if((pos/80) >= 24){  // Scroll up.
8010047b:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
80100481:	0f 8f a9 00 00 00    	jg     80100530 <consputc.part.0+0x130>
  outb(CRTPORT+1, pos>>8);
80100487:	89 f0                	mov    %esi,%eax
  crt[pos] = ' ' | 0x0700;
80100489:	8d b4 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
80100490:	88 45 e7             	mov    %al,-0x19(%ebp)
  outb(CRTPORT+1, pos>>8);
80100493:	0f b6 fc             	movzbl %ah,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100496:	bb d4 03 00 00       	mov    $0x3d4,%ebx
8010049b:	b8 0e 00 00 00       	mov    $0xe,%eax
801004a0:	89 da                	mov    %ebx,%edx
801004a2:	ee                   	out    %al,(%dx)
801004a3:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801004a8:	89 f8                	mov    %edi,%eax
801004aa:	89 ca                	mov    %ecx,%edx
801004ac:	ee                   	out    %al,(%dx)
801004ad:	b8 0f 00 00 00       	mov    $0xf,%eax
801004b2:	89 da                	mov    %ebx,%edx
801004b4:	ee                   	out    %al,(%dx)
801004b5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801004b9:	89 ca                	mov    %ecx,%edx
801004bb:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801004bc:	b8 20 07 00 00       	mov    $0x720,%eax
801004c1:	66 89 06             	mov    %ax,(%esi)
}
801004c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801004c7:	5b                   	pop    %ebx
801004c8:	5e                   	pop    %esi
801004c9:	5f                   	pop    %edi
801004ca:	5d                   	pop    %ebp
801004cb:	c3                   	ret    
801004cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(pos > 0) --pos;
801004d0:	8d 70 ff             	lea    -0x1(%eax),%esi
801004d3:	85 c0                	test   %eax,%eax
801004d5:	75 98                	jne    8010046f <consputc.part.0+0x6f>
801004d7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
801004db:	be 00 80 0b 80       	mov    $0x800b8000,%esi
801004e0:	31 ff                	xor    %edi,%edi
801004e2:	eb b2                	jmp    80100496 <consputc.part.0+0x96>
801004e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pos += 80 - pos%80;
801004e8:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801004ed:	f7 e2                	mul    %edx
801004ef:	c1 ea 06             	shr    $0x6,%edx
801004f2:	8d 04 92             	lea    (%edx,%edx,4),%eax
801004f5:	c1 e0 04             	shl    $0x4,%eax
801004f8:	8d 70 50             	lea    0x50(%eax),%esi
801004fb:	e9 6f ff ff ff       	jmp    8010046f <consputc.part.0+0x6f>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100500:	83 ec 0c             	sub    $0xc,%esp
80100503:	6a 08                	push   $0x8
80100505:	e8 16 62 00 00       	call   80106720 <uartputc>
8010050a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100511:	e8 0a 62 00 00       	call   80106720 <uartputc>
80100516:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010051d:	e8 fe 61 00 00       	call   80106720 <uartputc>
80100522:	83 c4 10             	add    $0x10,%esp
80100525:	e9 f8 fe ff ff       	jmp    80100422 <consputc.part.0+0x22>
8010052a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100530:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
80100533:	8d 5e b0             	lea    -0x50(%esi),%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100536:	8d b4 36 60 7f 0b 80 	lea    -0x7ff480a0(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
8010053d:	bf 07 00 00 00       	mov    $0x7,%edi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100542:	68 60 0e 00 00       	push   $0xe60
80100547:	68 a0 80 0b 80       	push   $0x800b80a0
8010054c:	68 00 80 0b 80       	push   $0x800b8000
80100551:	e8 6a 49 00 00       	call   80104ec0 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100556:	b8 80 07 00 00       	mov    $0x780,%eax
8010055b:	83 c4 0c             	add    $0xc,%esp
8010055e:	29 d8                	sub    %ebx,%eax
80100560:	01 c0                	add    %eax,%eax
80100562:	50                   	push   %eax
80100563:	6a 00                	push   $0x0
80100565:	56                   	push   %esi
80100566:	e8 b5 48 00 00       	call   80104e20 <memset>
  outb(CRTPORT+1, pos);
8010056b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010056e:	83 c4 10             	add    $0x10,%esp
80100571:	e9 20 ff ff ff       	jmp    80100496 <consputc.part.0+0x96>
    panic("pos under/overflow");
80100576:	83 ec 0c             	sub    $0xc,%esp
80100579:	68 05 7f 10 80       	push   $0x80107f05
8010057e:	e8 fd fd ff ff       	call   80100380 <panic>
80100583:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010058a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100590 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100590:	55                   	push   %ebp
80100591:	89 e5                	mov    %esp,%ebp
80100593:	57                   	push   %edi
80100594:	56                   	push   %esi
80100595:	53                   	push   %ebx
80100596:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100599:	ff 75 08             	push   0x8(%ebp)
{
8010059c:	8b 75 10             	mov    0x10(%ebp),%esi
  iunlock(ip);
8010059f:	e8 bc 12 00 00       	call   80101860 <iunlock>
  acquire(&cons.lock);
801005a4:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801005ab:	e8 b0 47 00 00       	call   80104d60 <acquire>
  for(i = 0; i < n; i++)
801005b0:	83 c4 10             	add    $0x10,%esp
801005b3:	85 f6                	test   %esi,%esi
801005b5:	7e 25                	jle    801005dc <consolewrite+0x4c>
801005b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801005ba:	8d 3c 33             	lea    (%ebx,%esi,1),%edi
  if(panicked){
801005bd:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
    consputc(buf[i] & 0xff);
801005c3:	0f b6 03             	movzbl (%ebx),%eax
  if(panicked){
801005c6:	85 d2                	test   %edx,%edx
801005c8:	74 06                	je     801005d0 <consolewrite+0x40>
  asm volatile("cli");
801005ca:	fa                   	cli    
    for(;;)
801005cb:	eb fe                	jmp    801005cb <consolewrite+0x3b>
801005cd:	8d 76 00             	lea    0x0(%esi),%esi
801005d0:	e8 2b fe ff ff       	call   80100400 <consputc.part.0>
  for(i = 0; i < n; i++)
801005d5:	83 c3 01             	add    $0x1,%ebx
801005d8:	39 df                	cmp    %ebx,%edi
801005da:	75 e1                	jne    801005bd <consolewrite+0x2d>
  release(&cons.lock);
801005dc:	83 ec 0c             	sub    $0xc,%esp
801005df:	68 20 ff 10 80       	push   $0x8010ff20
801005e4:	e8 17 47 00 00       	call   80104d00 <release>
  ilock(ip);
801005e9:	58                   	pop    %eax
801005ea:	ff 75 08             	push   0x8(%ebp)
801005ed:	e8 8e 11 00 00       	call   80101780 <ilock>

  return n;
}
801005f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005f5:	89 f0                	mov    %esi,%eax
801005f7:	5b                   	pop    %ebx
801005f8:	5e                   	pop    %esi
801005f9:	5f                   	pop    %edi
801005fa:	5d                   	pop    %ebp
801005fb:	c3                   	ret    
801005fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100600 <printint>:
{
80100600:	55                   	push   %ebp
80100601:	89 e5                	mov    %esp,%ebp
80100603:	57                   	push   %edi
80100604:	56                   	push   %esi
80100605:	53                   	push   %ebx
80100606:	83 ec 2c             	sub    $0x2c,%esp
80100609:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010060c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  if(sign && (sign = xx < 0))
8010060f:	85 c9                	test   %ecx,%ecx
80100611:	74 04                	je     80100617 <printint+0x17>
80100613:	85 c0                	test   %eax,%eax
80100615:	78 6d                	js     80100684 <printint+0x84>
    x = xx;
80100617:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010061e:	89 c1                	mov    %eax,%ecx
  i = 0;
80100620:	31 db                	xor    %ebx,%ebx
80100622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    buf[i++] = digits[x % base];
80100628:	89 c8                	mov    %ecx,%eax
8010062a:	31 d2                	xor    %edx,%edx
8010062c:	89 de                	mov    %ebx,%esi
8010062e:	89 cf                	mov    %ecx,%edi
80100630:	f7 75 d4             	divl   -0x2c(%ebp)
80100633:	8d 5b 01             	lea    0x1(%ebx),%ebx
80100636:	0f b6 92 30 7f 10 80 	movzbl -0x7fef80d0(%edx),%edx
  }while((x /= base) != 0);
8010063d:	89 c1                	mov    %eax,%ecx
    buf[i++] = digits[x % base];
8010063f:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
  }while((x /= base) != 0);
80100643:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
80100646:	73 e0                	jae    80100628 <printint+0x28>
  if(sign)
80100648:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010064b:	85 c9                	test   %ecx,%ecx
8010064d:	74 0c                	je     8010065b <printint+0x5b>
    buf[i++] = '-';
8010064f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
80100654:	89 de                	mov    %ebx,%esi
    buf[i++] = '-';
80100656:	ba 2d 00 00 00       	mov    $0x2d,%edx
  while(--i >= 0)
8010065b:	8d 5c 35 d7          	lea    -0x29(%ebp,%esi,1),%ebx
8010065f:	0f be c2             	movsbl %dl,%eax
  if(panicked){
80100662:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100668:	85 d2                	test   %edx,%edx
8010066a:	74 04                	je     80100670 <printint+0x70>
8010066c:	fa                   	cli    
    for(;;)
8010066d:	eb fe                	jmp    8010066d <printint+0x6d>
8010066f:	90                   	nop
80100670:	e8 8b fd ff ff       	call   80100400 <consputc.part.0>
  while(--i >= 0)
80100675:	8d 45 d7             	lea    -0x29(%ebp),%eax
80100678:	39 c3                	cmp    %eax,%ebx
8010067a:	74 0e                	je     8010068a <printint+0x8a>
    consputc(buf[i]);
8010067c:	0f be 03             	movsbl (%ebx),%eax
8010067f:	83 eb 01             	sub    $0x1,%ebx
80100682:	eb de                	jmp    80100662 <printint+0x62>
    x = -xx;
80100684:	f7 d8                	neg    %eax
80100686:	89 c1                	mov    %eax,%ecx
80100688:	eb 96                	jmp    80100620 <printint+0x20>
}
8010068a:	83 c4 2c             	add    $0x2c,%esp
8010068d:	5b                   	pop    %ebx
8010068e:	5e                   	pop    %esi
8010068f:	5f                   	pop    %edi
80100690:	5d                   	pop    %ebp
80100691:	c3                   	ret    
80100692:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801006a0 <cprintf>:
{
801006a0:	55                   	push   %ebp
801006a1:	89 e5                	mov    %esp,%ebp
801006a3:	57                   	push   %edi
801006a4:	56                   	push   %esi
801006a5:	53                   	push   %ebx
801006a6:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801006a9:	a1 54 ff 10 80       	mov    0x8010ff54,%eax
801006ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
801006b1:	85 c0                	test   %eax,%eax
801006b3:	0f 85 27 01 00 00    	jne    801007e0 <cprintf+0x140>
  if (fmt == 0)
801006b9:	8b 75 08             	mov    0x8(%ebp),%esi
801006bc:	85 f6                	test   %esi,%esi
801006be:	0f 84 ac 01 00 00    	je     80100870 <cprintf+0x1d0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006c4:	0f b6 06             	movzbl (%esi),%eax
  argp = (uint*)(void*)(&fmt + 1);
801006c7:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006ca:	31 db                	xor    %ebx,%ebx
801006cc:	85 c0                	test   %eax,%eax
801006ce:	74 56                	je     80100726 <cprintf+0x86>
    if(c != '%'){
801006d0:	83 f8 25             	cmp    $0x25,%eax
801006d3:	0f 85 cf 00 00 00    	jne    801007a8 <cprintf+0x108>
    c = fmt[++i] & 0xff;
801006d9:	83 c3 01             	add    $0x1,%ebx
801006dc:	0f b6 14 1e          	movzbl (%esi,%ebx,1),%edx
    if(c == 0)
801006e0:	85 d2                	test   %edx,%edx
801006e2:	74 42                	je     80100726 <cprintf+0x86>
    switch(c){
801006e4:	83 fa 70             	cmp    $0x70,%edx
801006e7:	0f 84 90 00 00 00    	je     8010077d <cprintf+0xdd>
801006ed:	7f 51                	jg     80100740 <cprintf+0xa0>
801006ef:	83 fa 25             	cmp    $0x25,%edx
801006f2:	0f 84 c0 00 00 00    	je     801007b8 <cprintf+0x118>
801006f8:	83 fa 64             	cmp    $0x64,%edx
801006fb:	0f 85 f4 00 00 00    	jne    801007f5 <cprintf+0x155>
      printint(*argp++, 10, 1);
80100701:	8d 47 04             	lea    0x4(%edi),%eax
80100704:	b9 01 00 00 00       	mov    $0x1,%ecx
80100709:	ba 0a 00 00 00       	mov    $0xa,%edx
8010070e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100711:	8b 07                	mov    (%edi),%eax
80100713:	e8 e8 fe ff ff       	call   80100600 <printint>
80100718:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010071b:	83 c3 01             	add    $0x1,%ebx
8010071e:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
80100722:	85 c0                	test   %eax,%eax
80100724:	75 aa                	jne    801006d0 <cprintf+0x30>
  if(locking)
80100726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100729:	85 c0                	test   %eax,%eax
8010072b:	0f 85 22 01 00 00    	jne    80100853 <cprintf+0x1b3>
}
80100731:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100734:	5b                   	pop    %ebx
80100735:	5e                   	pop    %esi
80100736:	5f                   	pop    %edi
80100737:	5d                   	pop    %ebp
80100738:	c3                   	ret    
80100739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100740:	83 fa 73             	cmp    $0x73,%edx
80100743:	75 33                	jne    80100778 <cprintf+0xd8>
      if((s = (char*)*argp++) == 0)
80100745:	8d 47 04             	lea    0x4(%edi),%eax
80100748:	8b 3f                	mov    (%edi),%edi
8010074a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010074d:	85 ff                	test   %edi,%edi
8010074f:	0f 84 e3 00 00 00    	je     80100838 <cprintf+0x198>
      for(; *s; s++)
80100755:	0f be 07             	movsbl (%edi),%eax
80100758:	84 c0                	test   %al,%al
8010075a:	0f 84 08 01 00 00    	je     80100868 <cprintf+0x1c8>
  if(panicked){
80100760:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100766:	85 d2                	test   %edx,%edx
80100768:	0f 84 b2 00 00 00    	je     80100820 <cprintf+0x180>
8010076e:	fa                   	cli    
    for(;;)
8010076f:	eb fe                	jmp    8010076f <cprintf+0xcf>
80100771:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100778:	83 fa 78             	cmp    $0x78,%edx
8010077b:	75 78                	jne    801007f5 <cprintf+0x155>
      printint(*argp++, 16, 0);
8010077d:	8d 47 04             	lea    0x4(%edi),%eax
80100780:	31 c9                	xor    %ecx,%ecx
80100782:	ba 10 00 00 00       	mov    $0x10,%edx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100787:	83 c3 01             	add    $0x1,%ebx
      printint(*argp++, 16, 0);
8010078a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010078d:	8b 07                	mov    (%edi),%eax
8010078f:	e8 6c fe ff ff       	call   80100600 <printint>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100794:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
      printint(*argp++, 16, 0);
80100798:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010079b:	85 c0                	test   %eax,%eax
8010079d:	0f 85 2d ff ff ff    	jne    801006d0 <cprintf+0x30>
801007a3:	eb 81                	jmp    80100726 <cprintf+0x86>
801007a5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801007a8:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
801007ae:	85 c9                	test   %ecx,%ecx
801007b0:	74 14                	je     801007c6 <cprintf+0x126>
801007b2:	fa                   	cli    
    for(;;)
801007b3:	eb fe                	jmp    801007b3 <cprintf+0x113>
801007b5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801007b8:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
801007bd:	85 c0                	test   %eax,%eax
801007bf:	75 6c                	jne    8010082d <cprintf+0x18d>
801007c1:	b8 25 00 00 00       	mov    $0x25,%eax
801007c6:	e8 35 fc ff ff       	call   80100400 <consputc.part.0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007cb:	83 c3 01             	add    $0x1,%ebx
801007ce:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
801007d2:	85 c0                	test   %eax,%eax
801007d4:	0f 85 f6 fe ff ff    	jne    801006d0 <cprintf+0x30>
801007da:	e9 47 ff ff ff       	jmp    80100726 <cprintf+0x86>
801007df:	90                   	nop
    acquire(&cons.lock);
801007e0:	83 ec 0c             	sub    $0xc,%esp
801007e3:	68 20 ff 10 80       	push   $0x8010ff20
801007e8:	e8 73 45 00 00       	call   80104d60 <acquire>
801007ed:	83 c4 10             	add    $0x10,%esp
801007f0:	e9 c4 fe ff ff       	jmp    801006b9 <cprintf+0x19>
  if(panicked){
801007f5:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
801007fb:	85 c9                	test   %ecx,%ecx
801007fd:	75 31                	jne    80100830 <cprintf+0x190>
801007ff:	b8 25 00 00 00       	mov    $0x25,%eax
80100804:	89 55 e0             	mov    %edx,-0x20(%ebp)
80100807:	e8 f4 fb ff ff       	call   80100400 <consputc.part.0>
8010080c:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100812:	85 d2                	test   %edx,%edx
80100814:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100817:	74 2e                	je     80100847 <cprintf+0x1a7>
80100819:	fa                   	cli    
    for(;;)
8010081a:	eb fe                	jmp    8010081a <cprintf+0x17a>
8010081c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100820:	e8 db fb ff ff       	call   80100400 <consputc.part.0>
      for(; *s; s++)
80100825:	83 c7 01             	add    $0x1,%edi
80100828:	e9 28 ff ff ff       	jmp    80100755 <cprintf+0xb5>
8010082d:	fa                   	cli    
    for(;;)
8010082e:	eb fe                	jmp    8010082e <cprintf+0x18e>
80100830:	fa                   	cli    
80100831:	eb fe                	jmp    80100831 <cprintf+0x191>
80100833:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100837:	90                   	nop
        s = "(null)";
80100838:	bf 18 7f 10 80       	mov    $0x80107f18,%edi
      for(; *s; s++)
8010083d:	b8 28 00 00 00       	mov    $0x28,%eax
80100842:	e9 19 ff ff ff       	jmp    80100760 <cprintf+0xc0>
80100847:	89 d0                	mov    %edx,%eax
80100849:	e8 b2 fb ff ff       	call   80100400 <consputc.part.0>
8010084e:	e9 c8 fe ff ff       	jmp    8010071b <cprintf+0x7b>
    release(&cons.lock);
80100853:	83 ec 0c             	sub    $0xc,%esp
80100856:	68 20 ff 10 80       	push   $0x8010ff20
8010085b:	e8 a0 44 00 00       	call   80104d00 <release>
80100860:	83 c4 10             	add    $0x10,%esp
}
80100863:	e9 c9 fe ff ff       	jmp    80100731 <cprintf+0x91>
      if((s = (char*)*argp++) == 0)
80100868:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010086b:	e9 ab fe ff ff       	jmp    8010071b <cprintf+0x7b>
    panic("null fmt");
80100870:	83 ec 0c             	sub    $0xc,%esp
80100873:	68 1f 7f 10 80       	push   $0x80107f1f
80100878:	e8 03 fb ff ff       	call   80100380 <panic>
8010087d:	8d 76 00             	lea    0x0(%esi),%esi

80100880 <consoleintr>:
{
80100880:	55                   	push   %ebp
80100881:	89 e5                	mov    %esp,%ebp
80100883:	57                   	push   %edi
80100884:	56                   	push   %esi
  int c, doprocdump = 0;
80100885:	31 f6                	xor    %esi,%esi
{
80100887:	53                   	push   %ebx
80100888:	83 ec 18             	sub    $0x18,%esp
8010088b:	8b 7d 08             	mov    0x8(%ebp),%edi
  acquire(&cons.lock);
8010088e:	68 20 ff 10 80       	push   $0x8010ff20
80100893:	e8 c8 44 00 00       	call   80104d60 <acquire>
  while((c = getc()) >= 0){
80100898:	83 c4 10             	add    $0x10,%esp
8010089b:	eb 1a                	jmp    801008b7 <consoleintr+0x37>
8010089d:	8d 76 00             	lea    0x0(%esi),%esi
    switch(c){
801008a0:	83 fb 08             	cmp    $0x8,%ebx
801008a3:	0f 84 d7 00 00 00    	je     80100980 <consoleintr+0x100>
801008a9:	83 fb 10             	cmp    $0x10,%ebx
801008ac:	0f 85 32 01 00 00    	jne    801009e4 <consoleintr+0x164>
801008b2:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
801008b7:	ff d7                	call   *%edi
801008b9:	89 c3                	mov    %eax,%ebx
801008bb:	85 c0                	test   %eax,%eax
801008bd:	0f 88 05 01 00 00    	js     801009c8 <consoleintr+0x148>
    switch(c){
801008c3:	83 fb 15             	cmp    $0x15,%ebx
801008c6:	74 78                	je     80100940 <consoleintr+0xc0>
801008c8:	7e d6                	jle    801008a0 <consoleintr+0x20>
801008ca:	83 fb 7f             	cmp    $0x7f,%ebx
801008cd:	0f 84 ad 00 00 00    	je     80100980 <consoleintr+0x100>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008d3:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
801008d8:	89 c2                	mov    %eax,%edx
801008da:	2b 15 00 ff 10 80    	sub    0x8010ff00,%edx
801008e0:	83 fa 7f             	cmp    $0x7f,%edx
801008e3:	77 d2                	ja     801008b7 <consoleintr+0x37>
        input.buf[input.e++ % INPUT_BUF] = c;
801008e5:	8d 48 01             	lea    0x1(%eax),%ecx
  if(panicked){
801008e8:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
        input.buf[input.e++ % INPUT_BUF] = c;
801008ee:	83 e0 7f             	and    $0x7f,%eax
801008f1:	89 0d 08 ff 10 80    	mov    %ecx,0x8010ff08
        c = (c == '\r') ? '\n' : c;
801008f7:	83 fb 0d             	cmp    $0xd,%ebx
801008fa:	0f 84 13 01 00 00    	je     80100a13 <consoleintr+0x193>
        input.buf[input.e++ % INPUT_BUF] = c;
80100900:	88 98 80 fe 10 80    	mov    %bl,-0x7fef0180(%eax)
  if(panicked){
80100906:	85 d2                	test   %edx,%edx
80100908:	0f 85 10 01 00 00    	jne    80100a1e <consoleintr+0x19e>
8010090e:	89 d8                	mov    %ebx,%eax
80100910:	e8 eb fa ff ff       	call   80100400 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100915:	83 fb 0a             	cmp    $0xa,%ebx
80100918:	0f 84 14 01 00 00    	je     80100a32 <consoleintr+0x1b2>
8010091e:	83 fb 04             	cmp    $0x4,%ebx
80100921:	0f 84 0b 01 00 00    	je     80100a32 <consoleintr+0x1b2>
80100927:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010092c:	83 e8 80             	sub    $0xffffff80,%eax
8010092f:	39 05 08 ff 10 80    	cmp    %eax,0x8010ff08
80100935:	75 80                	jne    801008b7 <consoleintr+0x37>
80100937:	e9 fb 00 00 00       	jmp    80100a37 <consoleintr+0x1b7>
8010093c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      while(input.e != input.w &&
80100940:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100945:	39 05 04 ff 10 80    	cmp    %eax,0x8010ff04
8010094b:	0f 84 66 ff ff ff    	je     801008b7 <consoleintr+0x37>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100951:	83 e8 01             	sub    $0x1,%eax
80100954:	89 c2                	mov    %eax,%edx
80100956:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100959:	80 ba 80 fe 10 80 0a 	cmpb   $0xa,-0x7fef0180(%edx)
80100960:	0f 84 51 ff ff ff    	je     801008b7 <consoleintr+0x37>
  if(panicked){
80100966:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
        input.e--;
8010096c:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100971:	85 d2                	test   %edx,%edx
80100973:	74 33                	je     801009a8 <consoleintr+0x128>
80100975:	fa                   	cli    
    for(;;)
80100976:	eb fe                	jmp    80100976 <consoleintr+0xf6>
80100978:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010097f:	90                   	nop
      if(input.e != input.w){
80100980:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100985:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
8010098b:	0f 84 26 ff ff ff    	je     801008b7 <consoleintr+0x37>
        input.e--;
80100991:	83 e8 01             	sub    $0x1,%eax
80100994:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100999:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
8010099e:	85 c0                	test   %eax,%eax
801009a0:	74 56                	je     801009f8 <consoleintr+0x178>
801009a2:	fa                   	cli    
    for(;;)
801009a3:	eb fe                	jmp    801009a3 <consoleintr+0x123>
801009a5:	8d 76 00             	lea    0x0(%esi),%esi
801009a8:	b8 00 01 00 00       	mov    $0x100,%eax
801009ad:	e8 4e fa ff ff       	call   80100400 <consputc.part.0>
      while(input.e != input.w &&
801009b2:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
801009b7:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801009bd:	75 92                	jne    80100951 <consoleintr+0xd1>
801009bf:	e9 f3 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
801009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&cons.lock);
801009c8:	83 ec 0c             	sub    $0xc,%esp
801009cb:	68 20 ff 10 80       	push   $0x8010ff20
801009d0:	e8 2b 43 00 00       	call   80104d00 <release>
  if(doprocdump) {
801009d5:	83 c4 10             	add    $0x10,%esp
801009d8:	85 f6                	test   %esi,%esi
801009da:	75 2b                	jne    80100a07 <consoleintr+0x187>
}
801009dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801009df:	5b                   	pop    %ebx
801009e0:	5e                   	pop    %esi
801009e1:	5f                   	pop    %edi
801009e2:	5d                   	pop    %ebp
801009e3:	c3                   	ret    
      if(c != 0 && input.e-input.r < INPUT_BUF){
801009e4:	85 db                	test   %ebx,%ebx
801009e6:	0f 84 cb fe ff ff    	je     801008b7 <consoleintr+0x37>
801009ec:	e9 e2 fe ff ff       	jmp    801008d3 <consoleintr+0x53>
801009f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801009f8:	b8 00 01 00 00       	mov    $0x100,%eax
801009fd:	e8 fe f9 ff ff       	call   80100400 <consputc.part.0>
80100a02:	e9 b0 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
}
80100a07:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100a0a:	5b                   	pop    %ebx
80100a0b:	5e                   	pop    %esi
80100a0c:	5f                   	pop    %edi
80100a0d:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100a0e:	e9 3d 3b 00 00       	jmp    80104550 <procdump>
        input.buf[input.e++ % INPUT_BUF] = c;
80100a13:	c6 80 80 fe 10 80 0a 	movb   $0xa,-0x7fef0180(%eax)
  if(panicked){
80100a1a:	85 d2                	test   %edx,%edx
80100a1c:	74 0a                	je     80100a28 <consoleintr+0x1a8>
80100a1e:	fa                   	cli    
    for(;;)
80100a1f:	eb fe                	jmp    80100a1f <consoleintr+0x19f>
80100a21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a28:	b8 0a 00 00 00       	mov    $0xa,%eax
80100a2d:	e8 ce f9 ff ff       	call   80100400 <consputc.part.0>
          input.w = input.e;
80100a32:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
          wakeup(&input.r);
80100a37:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100a3a:	a3 04 ff 10 80       	mov    %eax,0x8010ff04
          wakeup(&input.r);
80100a3f:	68 00 ff 10 80       	push   $0x8010ff00
80100a44:	e8 27 3a 00 00       	call   80104470 <wakeup>
80100a49:	83 c4 10             	add    $0x10,%esp
80100a4c:	e9 66 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
80100a51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a5f:	90                   	nop

80100a60 <consoleinit>:

void
consoleinit(void)
{
80100a60:	55                   	push   %ebp
80100a61:	89 e5                	mov    %esp,%ebp
80100a63:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100a66:	68 28 7f 10 80       	push   $0x80107f28
80100a6b:	68 20 ff 10 80       	push   $0x8010ff20
80100a70:	e8 1b 41 00 00       	call   80104b90 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100a75:	58                   	pop    %eax
80100a76:	5a                   	pop    %edx
80100a77:	6a 00                	push   $0x0
80100a79:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100a7b:	c7 05 0c 09 11 80 90 	movl   $0x80100590,0x8011090c
80100a82:	05 10 80 
  devsw[CONSOLE].read = consoleread;
80100a85:	c7 05 08 09 11 80 80 	movl   $0x80100280,0x80110908
80100a8c:	02 10 80 
  cons.locking = 1;
80100a8f:	c7 05 54 ff 10 80 01 	movl   $0x1,0x8010ff54
80100a96:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100a99:	e8 e2 19 00 00       	call   80102480 <ioapicenable>
}
80100a9e:	83 c4 10             	add    $0x10,%esp
80100aa1:	c9                   	leave  
80100aa2:	c3                   	ret    
80100aa3:	66 90                	xchg   %ax,%ax
80100aa5:	66 90                	xchg   %ax,%ax
80100aa7:	66 90                	xchg   %ax,%ax
80100aa9:	66 90                	xchg   %ax,%ax
80100aab:	66 90                	xchg   %ax,%ax
80100aad:	66 90                	xchg   %ax,%ax
80100aaf:	90                   	nop

80100ab0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	57                   	push   %edi
80100ab4:	56                   	push   %esi
80100ab5:	53                   	push   %ebx
80100ab6:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100abc:	e8 0f 2f 00 00       	call   801039d0 <myproc>
80100ac1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100ac7:	e8 94 22 00 00       	call   80102d60 <begin_op>

  if((ip = namei(path)) == 0){
80100acc:	83 ec 0c             	sub    $0xc,%esp
80100acf:	ff 75 08             	push   0x8(%ebp)
80100ad2:	e8 c9 15 00 00       	call   801020a0 <namei>
80100ad7:	83 c4 10             	add    $0x10,%esp
80100ada:	85 c0                	test   %eax,%eax
80100adc:	0f 84 02 03 00 00    	je     80100de4 <exec+0x334>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100ae2:	83 ec 0c             	sub    $0xc,%esp
80100ae5:	89 c3                	mov    %eax,%ebx
80100ae7:	50                   	push   %eax
80100ae8:	e8 93 0c 00 00       	call   80101780 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100aed:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100af3:	6a 34                	push   $0x34
80100af5:	6a 00                	push   $0x0
80100af7:	50                   	push   %eax
80100af8:	53                   	push   %ebx
80100af9:	e8 92 0f 00 00       	call   80101a90 <readi>
80100afe:	83 c4 20             	add    $0x20,%esp
80100b01:	83 f8 34             	cmp    $0x34,%eax
80100b04:	74 22                	je     80100b28 <exec+0x78>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	53                   	push   %ebx
80100b0a:	e8 01 0f 00 00       	call   80101a10 <iunlockput>
    end_op();
80100b0f:	e8 bc 22 00 00       	call   80102dd0 <end_op>
80100b14:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100b17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100b1f:	5b                   	pop    %ebx
80100b20:	5e                   	pop    %esi
80100b21:	5f                   	pop    %edi
80100b22:	5d                   	pop    %ebp
80100b23:	c3                   	ret    
80100b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(elf.magic != ELF_MAGIC)
80100b28:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100b2f:	45 4c 46 
80100b32:	75 d2                	jne    80100b06 <exec+0x56>
  if((pgdir = setupkvm()) == 0)
80100b34:	e8 77 6d 00 00       	call   801078b0 <setupkvm>
80100b39:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100b3f:	85 c0                	test   %eax,%eax
80100b41:	74 c3                	je     80100b06 <exec+0x56>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b43:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100b4a:	00 
80100b4b:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100b51:	0f 84 ac 02 00 00    	je     80100e03 <exec+0x353>
  sz = 0;
80100b57:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100b5e:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b61:	31 ff                	xor    %edi,%edi
80100b63:	e9 8e 00 00 00       	jmp    80100bf6 <exec+0x146>
80100b68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b6f:	90                   	nop
    if(ph.type != ELF_PROG_LOAD)
80100b70:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100b77:	75 6c                	jne    80100be5 <exec+0x135>
    if(ph.memsz < ph.filesz)
80100b79:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100b7f:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100b85:	0f 82 87 00 00 00    	jb     80100c12 <exec+0x162>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100b8b:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100b91:	72 7f                	jb     80100c12 <exec+0x162>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100b93:	83 ec 04             	sub    $0x4,%esp
80100b96:	50                   	push   %eax
80100b97:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b9d:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100ba3:	e8 28 6b 00 00       	call   801076d0 <allocuvm>
80100ba8:	83 c4 10             	add    $0x10,%esp
80100bab:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100bb1:	85 c0                	test   %eax,%eax
80100bb3:	74 5d                	je     80100c12 <exec+0x162>
    if(ph.vaddr % PGSIZE != 0)
80100bb5:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bbb:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100bc0:	75 50                	jne    80100c12 <exec+0x162>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100bc2:	83 ec 0c             	sub    $0xc,%esp
80100bc5:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100bcb:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100bd1:	53                   	push   %ebx
80100bd2:	50                   	push   %eax
80100bd3:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100bd9:	e8 02 6a 00 00       	call   801075e0 <loaduvm>
80100bde:	83 c4 20             	add    $0x20,%esp
80100be1:	85 c0                	test   %eax,%eax
80100be3:	78 2d                	js     80100c12 <exec+0x162>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100be5:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100bec:	83 c7 01             	add    $0x1,%edi
80100bef:	83 c6 20             	add    $0x20,%esi
80100bf2:	39 f8                	cmp    %edi,%eax
80100bf4:	7e 3a                	jle    80100c30 <exec+0x180>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bf6:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100bfc:	6a 20                	push   $0x20
80100bfe:	56                   	push   %esi
80100bff:	50                   	push   %eax
80100c00:	53                   	push   %ebx
80100c01:	e8 8a 0e 00 00       	call   80101a90 <readi>
80100c06:	83 c4 10             	add    $0x10,%esp
80100c09:	83 f8 20             	cmp    $0x20,%eax
80100c0c:	0f 84 5e ff ff ff    	je     80100b70 <exec+0xc0>
    freevm(pgdir);
80100c12:	83 ec 0c             	sub    $0xc,%esp
80100c15:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100c1b:	e8 10 6c 00 00       	call   80107830 <freevm>
  if(ip){
80100c20:	83 c4 10             	add    $0x10,%esp
80100c23:	e9 de fe ff ff       	jmp    80100b06 <exec+0x56>
80100c28:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100c2f:	90                   	nop
  sz = PGROUNDUP(sz);
80100c30:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100c36:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100c3c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c42:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100c48:	83 ec 0c             	sub    $0xc,%esp
80100c4b:	53                   	push   %ebx
80100c4c:	e8 bf 0d 00 00       	call   80101a10 <iunlockput>
  end_op();
80100c51:	e8 7a 21 00 00       	call   80102dd0 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c56:	83 c4 0c             	add    $0xc,%esp
80100c59:	56                   	push   %esi
80100c5a:	57                   	push   %edi
80100c5b:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100c61:	57                   	push   %edi
80100c62:	e8 69 6a 00 00       	call   801076d0 <allocuvm>
80100c67:	83 c4 10             	add    $0x10,%esp
80100c6a:	89 c6                	mov    %eax,%esi
80100c6c:	85 c0                	test   %eax,%eax
80100c6e:	0f 84 94 00 00 00    	je     80100d08 <exec+0x258>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c74:	83 ec 08             	sub    $0x8,%esp
80100c77:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  for(argc = 0; argv[argc]; argc++) {
80100c7d:	89 f3                	mov    %esi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c7f:	50                   	push   %eax
80100c80:	57                   	push   %edi
  for(argc = 0; argv[argc]; argc++) {
80100c81:	31 ff                	xor    %edi,%edi
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c83:	e8 c8 6c 00 00       	call   80107950 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100c88:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c8b:	83 c4 10             	add    $0x10,%esp
80100c8e:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100c94:	8b 00                	mov    (%eax),%eax
80100c96:	85 c0                	test   %eax,%eax
80100c98:	0f 84 8b 00 00 00    	je     80100d29 <exec+0x279>
80100c9e:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100ca4:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100caa:	eb 23                	jmp    80100ccf <exec+0x21f>
80100cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100cb3:	89 9c bd 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100cba:	83 c7 01             	add    $0x1,%edi
    ustack[3+argc] = sp;
80100cbd:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100cc3:	8b 04 b8             	mov    (%eax,%edi,4),%eax
80100cc6:	85 c0                	test   %eax,%eax
80100cc8:	74 59                	je     80100d23 <exec+0x273>
    if(argc >= MAXARG)
80100cca:	83 ff 20             	cmp    $0x20,%edi
80100ccd:	74 39                	je     80100d08 <exec+0x258>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ccf:	83 ec 0c             	sub    $0xc,%esp
80100cd2:	50                   	push   %eax
80100cd3:	e8 48 43 00 00       	call   80105020 <strlen>
80100cd8:	29 c3                	sub    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100cda:	58                   	pop    %eax
80100cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cde:	83 eb 01             	sub    $0x1,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ce1:	ff 34 b8             	push   (%eax,%edi,4)
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ce4:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ce7:	e8 34 43 00 00       	call   80105020 <strlen>
80100cec:	83 c0 01             	add    $0x1,%eax
80100cef:	50                   	push   %eax
80100cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cf3:	ff 34 b8             	push   (%eax,%edi,4)
80100cf6:	53                   	push   %ebx
80100cf7:	56                   	push   %esi
80100cf8:	e8 23 6e 00 00       	call   80107b20 <copyout>
80100cfd:	83 c4 20             	add    $0x20,%esp
80100d00:	85 c0                	test   %eax,%eax
80100d02:	79 ac                	jns    80100cb0 <exec+0x200>
80100d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    freevm(pgdir);
80100d08:	83 ec 0c             	sub    $0xc,%esp
80100d0b:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d11:	e8 1a 6b 00 00       	call   80107830 <freevm>
80100d16:	83 c4 10             	add    $0x10,%esp
  return -1;
80100d19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d1e:	e9 f9 fd ff ff       	jmp    80100b1c <exec+0x6c>
80100d23:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d29:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100d30:	89 d9                	mov    %ebx,%ecx
  ustack[3+argc] = 0;
80100d32:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100d39:	00 00 00 00 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d3d:	29 c1                	sub    %eax,%ecx
  sp -= (3+argc+1) * 4;
80100d3f:	83 c0 0c             	add    $0xc,%eax
  ustack[1] = argc;
80100d42:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  sp -= (3+argc+1) * 4;
80100d48:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100d4a:	50                   	push   %eax
80100d4b:	52                   	push   %edx
80100d4c:	53                   	push   %ebx
80100d4d:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
  ustack[0] = 0xffffffff;  // fake return PC
80100d53:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100d5a:	ff ff ff 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d5d:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100d63:	e8 b8 6d 00 00       	call   80107b20 <copyout>
80100d68:	83 c4 10             	add    $0x10,%esp
80100d6b:	85 c0                	test   %eax,%eax
80100d6d:	78 99                	js     80100d08 <exec+0x258>
  for(last=s=path; *s; s++)
80100d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80100d72:	8b 55 08             	mov    0x8(%ebp),%edx
80100d75:	0f b6 00             	movzbl (%eax),%eax
80100d78:	84 c0                	test   %al,%al
80100d7a:	74 13                	je     80100d8f <exec+0x2df>
80100d7c:	89 d1                	mov    %edx,%ecx
80100d7e:	66 90                	xchg   %ax,%ax
      last = s+1;
80100d80:	83 c1 01             	add    $0x1,%ecx
80100d83:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100d85:	0f b6 01             	movzbl (%ecx),%eax
      last = s+1;
80100d88:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100d8b:	84 c0                	test   %al,%al
80100d8d:	75 f1                	jne    80100d80 <exec+0x2d0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100d8f:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100d95:	83 ec 04             	sub    $0x4,%esp
80100d98:	6a 10                	push   $0x10
80100d9a:	89 f8                	mov    %edi,%eax
80100d9c:	52                   	push   %edx
80100d9d:	83 c0 6c             	add    $0x6c,%eax
80100da0:	50                   	push   %eax
80100da1:	e8 3a 42 00 00       	call   80104fe0 <safestrcpy>
  curproc->pgdir = pgdir;
80100da6:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  oldpgdir = curproc->pgdir;
80100dac:	89 f8                	mov    %edi,%eax
80100dae:	8b 7f 04             	mov    0x4(%edi),%edi
  curproc->sz = sz;
80100db1:	89 30                	mov    %esi,(%eax)
  curproc->pgdir = pgdir;
80100db3:	89 48 04             	mov    %ecx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100db6:	89 c1                	mov    %eax,%ecx
80100db8:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100dbe:	8b 40 18             	mov    0x18(%eax),%eax
80100dc1:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100dc4:	8b 41 18             	mov    0x18(%ecx),%eax
80100dc7:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100dca:	89 0c 24             	mov    %ecx,(%esp)
80100dcd:	e8 7e 66 00 00       	call   80107450 <switchuvm>
  freevm(oldpgdir);
80100dd2:	89 3c 24             	mov    %edi,(%esp)
80100dd5:	e8 56 6a 00 00       	call   80107830 <freevm>
  return 0;
80100dda:	83 c4 10             	add    $0x10,%esp
80100ddd:	31 c0                	xor    %eax,%eax
80100ddf:	e9 38 fd ff ff       	jmp    80100b1c <exec+0x6c>
    end_op();
80100de4:	e8 e7 1f 00 00       	call   80102dd0 <end_op>
    cprintf("exec: fail\n");
80100de9:	83 ec 0c             	sub    $0xc,%esp
80100dec:	68 41 7f 10 80       	push   $0x80107f41
80100df1:	e8 aa f8 ff ff       	call   801006a0 <cprintf>
    return -1;
80100df6:	83 c4 10             	add    $0x10,%esp
80100df9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dfe:	e9 19 fd ff ff       	jmp    80100b1c <exec+0x6c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e03:	be 00 20 00 00       	mov    $0x2000,%esi
80100e08:	31 ff                	xor    %edi,%edi
80100e0a:	e9 39 fe ff ff       	jmp    80100c48 <exec+0x198>
80100e0f:	90                   	nop

80100e10 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100e10:	55                   	push   %ebp
80100e11:	89 e5                	mov    %esp,%ebp
80100e13:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100e16:	68 4d 7f 10 80       	push   $0x80107f4d
80100e1b:	68 60 ff 10 80       	push   $0x8010ff60
80100e20:	e8 6b 3d 00 00       	call   80104b90 <initlock>
}
80100e25:	83 c4 10             	add    $0x10,%esp
80100e28:	c9                   	leave  
80100e29:	c3                   	ret    
80100e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100e30 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100e30:	55                   	push   %ebp
80100e31:	89 e5                	mov    %esp,%ebp
80100e33:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e34:	bb 94 ff 10 80       	mov    $0x8010ff94,%ebx
{
80100e39:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100e3c:	68 60 ff 10 80       	push   $0x8010ff60
80100e41:	e8 1a 3f 00 00       	call   80104d60 <acquire>
80100e46:	83 c4 10             	add    $0x10,%esp
80100e49:	eb 10                	jmp    80100e5b <filealloc+0x2b>
80100e4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100e4f:	90                   	nop
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e50:	83 c3 18             	add    $0x18,%ebx
80100e53:	81 fb f4 08 11 80    	cmp    $0x801108f4,%ebx
80100e59:	74 25                	je     80100e80 <filealloc+0x50>
    if(f->ref == 0){
80100e5b:	8b 43 04             	mov    0x4(%ebx),%eax
80100e5e:	85 c0                	test   %eax,%eax
80100e60:	75 ee                	jne    80100e50 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100e62:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100e65:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100e6c:	68 60 ff 10 80       	push   $0x8010ff60
80100e71:	e8 8a 3e 00 00       	call   80104d00 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100e76:	89 d8                	mov    %ebx,%eax
      return f;
80100e78:	83 c4 10             	add    $0x10,%esp
}
80100e7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e7e:	c9                   	leave  
80100e7f:	c3                   	ret    
  release(&ftable.lock);
80100e80:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100e83:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100e85:	68 60 ff 10 80       	push   $0x8010ff60
80100e8a:	e8 71 3e 00 00       	call   80104d00 <release>
}
80100e8f:	89 d8                	mov    %ebx,%eax
  return 0;
80100e91:	83 c4 10             	add    $0x10,%esp
}
80100e94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e97:	c9                   	leave  
80100e98:	c3                   	ret    
80100e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100ea0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100ea0:	55                   	push   %ebp
80100ea1:	89 e5                	mov    %esp,%ebp
80100ea3:	53                   	push   %ebx
80100ea4:	83 ec 10             	sub    $0x10,%esp
80100ea7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100eaa:	68 60 ff 10 80       	push   $0x8010ff60
80100eaf:	e8 ac 3e 00 00       	call   80104d60 <acquire>
  if(f->ref < 1)
80100eb4:	8b 43 04             	mov    0x4(%ebx),%eax
80100eb7:	83 c4 10             	add    $0x10,%esp
80100eba:	85 c0                	test   %eax,%eax
80100ebc:	7e 1a                	jle    80100ed8 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100ebe:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100ec1:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100ec4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ec7:	68 60 ff 10 80       	push   $0x8010ff60
80100ecc:	e8 2f 3e 00 00       	call   80104d00 <release>
  return f;
}
80100ed1:	89 d8                	mov    %ebx,%eax
80100ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ed6:	c9                   	leave  
80100ed7:	c3                   	ret    
    panic("filedup");
80100ed8:	83 ec 0c             	sub    $0xc,%esp
80100edb:	68 54 7f 10 80       	push   $0x80107f54
80100ee0:	e8 9b f4 ff ff       	call   80100380 <panic>
80100ee5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100ef0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100ef0:	55                   	push   %ebp
80100ef1:	89 e5                	mov    %esp,%ebp
80100ef3:	57                   	push   %edi
80100ef4:	56                   	push   %esi
80100ef5:	53                   	push   %ebx
80100ef6:	83 ec 28             	sub    $0x28,%esp
80100ef9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100efc:	68 60 ff 10 80       	push   $0x8010ff60
80100f01:	e8 5a 3e 00 00       	call   80104d60 <acquire>
  if(f->ref < 1)
80100f06:	8b 53 04             	mov    0x4(%ebx),%edx
80100f09:	83 c4 10             	add    $0x10,%esp
80100f0c:	85 d2                	test   %edx,%edx
80100f0e:	0f 8e a5 00 00 00    	jle    80100fb9 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80100f14:	83 ea 01             	sub    $0x1,%edx
80100f17:	89 53 04             	mov    %edx,0x4(%ebx)
80100f1a:	75 44                	jne    80100f60 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100f1c:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100f20:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80100f23:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80100f25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
80100f2b:	8b 73 0c             	mov    0xc(%ebx),%esi
80100f2e:	88 45 e7             	mov    %al,-0x19(%ebp)
80100f31:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80100f34:	68 60 ff 10 80       	push   $0x8010ff60
  ff = *f;
80100f39:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80100f3c:	e8 bf 3d 00 00       	call   80104d00 <release>

  if(ff.type == FD_PIPE)
80100f41:	83 c4 10             	add    $0x10,%esp
80100f44:	83 ff 01             	cmp    $0x1,%edi
80100f47:	74 57                	je     80100fa0 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100f49:	83 ff 02             	cmp    $0x2,%edi
80100f4c:	74 2a                	je     80100f78 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f51:	5b                   	pop    %ebx
80100f52:	5e                   	pop    %esi
80100f53:	5f                   	pop    %edi
80100f54:	5d                   	pop    %ebp
80100f55:	c3                   	ret    
80100f56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100f5d:	8d 76 00             	lea    0x0(%esi),%esi
    release(&ftable.lock);
80100f60:	c7 45 08 60 ff 10 80 	movl   $0x8010ff60,0x8(%ebp)
}
80100f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f6a:	5b                   	pop    %ebx
80100f6b:	5e                   	pop    %esi
80100f6c:	5f                   	pop    %edi
80100f6d:	5d                   	pop    %ebp
    release(&ftable.lock);
80100f6e:	e9 8d 3d 00 00       	jmp    80104d00 <release>
80100f73:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100f77:	90                   	nop
    begin_op();
80100f78:	e8 e3 1d 00 00       	call   80102d60 <begin_op>
    iput(ff.ip);
80100f7d:	83 ec 0c             	sub    $0xc,%esp
80100f80:	ff 75 e0             	push   -0x20(%ebp)
80100f83:	e8 28 09 00 00       	call   801018b0 <iput>
    end_op();
80100f88:	83 c4 10             	add    $0x10,%esp
}
80100f8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f8e:	5b                   	pop    %ebx
80100f8f:	5e                   	pop    %esi
80100f90:	5f                   	pop    %edi
80100f91:	5d                   	pop    %ebp
    end_op();
80100f92:	e9 39 1e 00 00       	jmp    80102dd0 <end_op>
80100f97:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100f9e:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
80100fa0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
80100fa4:	83 ec 08             	sub    $0x8,%esp
80100fa7:	53                   	push   %ebx
80100fa8:	56                   	push   %esi
80100fa9:	e8 82 25 00 00       	call   80103530 <pipeclose>
80100fae:	83 c4 10             	add    $0x10,%esp
}
80100fb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fb4:	5b                   	pop    %ebx
80100fb5:	5e                   	pop    %esi
80100fb6:	5f                   	pop    %edi
80100fb7:	5d                   	pop    %ebp
80100fb8:	c3                   	ret    
    panic("fileclose");
80100fb9:	83 ec 0c             	sub    $0xc,%esp
80100fbc:	68 5c 7f 10 80       	push   $0x80107f5c
80100fc1:	e8 ba f3 ff ff       	call   80100380 <panic>
80100fc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100fcd:	8d 76 00             	lea    0x0(%esi),%esi

80100fd0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100fd0:	55                   	push   %ebp
80100fd1:	89 e5                	mov    %esp,%ebp
80100fd3:	53                   	push   %ebx
80100fd4:	83 ec 04             	sub    $0x4,%esp
80100fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100fda:	83 3b 02             	cmpl   $0x2,(%ebx)
80100fdd:	75 31                	jne    80101010 <filestat+0x40>
    ilock(f->ip);
80100fdf:	83 ec 0c             	sub    $0xc,%esp
80100fe2:	ff 73 10             	push   0x10(%ebx)
80100fe5:	e8 96 07 00 00       	call   80101780 <ilock>
    stati(f->ip, st);
80100fea:	58                   	pop    %eax
80100feb:	5a                   	pop    %edx
80100fec:	ff 75 0c             	push   0xc(%ebp)
80100fef:	ff 73 10             	push   0x10(%ebx)
80100ff2:	e8 69 0a 00 00       	call   80101a60 <stati>
    iunlock(f->ip);
80100ff7:	59                   	pop    %ecx
80100ff8:	ff 73 10             	push   0x10(%ebx)
80100ffb:	e8 60 08 00 00       	call   80101860 <iunlock>
    return 0;
  }
  return -1;
}
80101000:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
80101003:	83 c4 10             	add    $0x10,%esp
80101006:	31 c0                	xor    %eax,%eax
}
80101008:	c9                   	leave  
80101009:	c3                   	ret    
8010100a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101010:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80101013:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101018:	c9                   	leave  
80101019:	c3                   	ret    
8010101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101020 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101020:	55                   	push   %ebp
80101021:	89 e5                	mov    %esp,%ebp
80101023:	57                   	push   %edi
80101024:	56                   	push   %esi
80101025:	53                   	push   %ebx
80101026:	83 ec 0c             	sub    $0xc,%esp
80101029:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010102c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010102f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101032:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80101036:	74 60                	je     80101098 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80101038:	8b 03                	mov    (%ebx),%eax
8010103a:	83 f8 01             	cmp    $0x1,%eax
8010103d:	74 41                	je     80101080 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010103f:	83 f8 02             	cmp    $0x2,%eax
80101042:	75 5b                	jne    8010109f <fileread+0x7f>
    ilock(f->ip);
80101044:	83 ec 0c             	sub    $0xc,%esp
80101047:	ff 73 10             	push   0x10(%ebx)
8010104a:	e8 31 07 00 00       	call   80101780 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010104f:	57                   	push   %edi
80101050:	ff 73 14             	push   0x14(%ebx)
80101053:	56                   	push   %esi
80101054:	ff 73 10             	push   0x10(%ebx)
80101057:	e8 34 0a 00 00       	call   80101a90 <readi>
8010105c:	83 c4 20             	add    $0x20,%esp
8010105f:	89 c6                	mov    %eax,%esi
80101061:	85 c0                	test   %eax,%eax
80101063:	7e 03                	jle    80101068 <fileread+0x48>
      f->off += r;
80101065:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101068:	83 ec 0c             	sub    $0xc,%esp
8010106b:	ff 73 10             	push   0x10(%ebx)
8010106e:	e8 ed 07 00 00       	call   80101860 <iunlock>
    return r;
80101073:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80101076:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101079:	89 f0                	mov    %esi,%eax
8010107b:	5b                   	pop    %ebx
8010107c:	5e                   	pop    %esi
8010107d:	5f                   	pop    %edi
8010107e:	5d                   	pop    %ebp
8010107f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80101080:	8b 43 0c             	mov    0xc(%ebx),%eax
80101083:	89 45 08             	mov    %eax,0x8(%ebp)
}
80101086:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101089:	5b                   	pop    %ebx
8010108a:	5e                   	pop    %esi
8010108b:	5f                   	pop    %edi
8010108c:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
8010108d:	e9 3e 26 00 00       	jmp    801036d0 <piperead>
80101092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80101098:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010109d:	eb d7                	jmp    80101076 <fileread+0x56>
  panic("fileread");
8010109f:	83 ec 0c             	sub    $0xc,%esp
801010a2:	68 66 7f 10 80       	push   $0x80107f66
801010a7:	e8 d4 f2 ff ff       	call   80100380 <panic>
801010ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801010b0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801010b0:	55                   	push   %ebp
801010b1:	89 e5                	mov    %esp,%ebp
801010b3:	57                   	push   %edi
801010b4:	56                   	push   %esi
801010b5:	53                   	push   %ebx
801010b6:	83 ec 1c             	sub    $0x1c,%esp
801010b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801010bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
801010bf:	89 45 dc             	mov    %eax,-0x24(%ebp)
801010c2:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
801010c5:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
{
801010c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
801010cc:	0f 84 bd 00 00 00    	je     8010118f <filewrite+0xdf>
    return -1;
  if(f->type == FD_PIPE)
801010d2:	8b 03                	mov    (%ebx),%eax
801010d4:	83 f8 01             	cmp    $0x1,%eax
801010d7:	0f 84 bf 00 00 00    	je     8010119c <filewrite+0xec>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
801010dd:	83 f8 02             	cmp    $0x2,%eax
801010e0:	0f 85 c8 00 00 00    	jne    801011ae <filewrite+0xfe>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801010e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
801010e9:	31 f6                	xor    %esi,%esi
    while(i < n){
801010eb:	85 c0                	test   %eax,%eax
801010ed:	7f 30                	jg     8010111f <filewrite+0x6f>
801010ef:	e9 94 00 00 00       	jmp    80101188 <filewrite+0xd8>
801010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
801010f8:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
801010fb:	83 ec 0c             	sub    $0xc,%esp
801010fe:	ff 73 10             	push   0x10(%ebx)
        f->off += r;
80101101:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101104:	e8 57 07 00 00       	call   80101860 <iunlock>
      end_op();
80101109:	e8 c2 1c 00 00       	call   80102dd0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
8010110e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101111:	83 c4 10             	add    $0x10,%esp
80101114:	39 c7                	cmp    %eax,%edi
80101116:	75 5c                	jne    80101174 <filewrite+0xc4>
        panic("short filewrite");
      i += r;
80101118:	01 fe                	add    %edi,%esi
    while(i < n){
8010111a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
8010111d:	7e 69                	jle    80101188 <filewrite+0xd8>
      int n1 = n - i;
8010111f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101122:	b8 00 06 00 00       	mov    $0x600,%eax
80101127:	29 f7                	sub    %esi,%edi
80101129:	39 c7                	cmp    %eax,%edi
8010112b:	0f 4f f8             	cmovg  %eax,%edi
      begin_op();
8010112e:	e8 2d 1c 00 00       	call   80102d60 <begin_op>
      ilock(f->ip);
80101133:	83 ec 0c             	sub    $0xc,%esp
80101136:	ff 73 10             	push   0x10(%ebx)
80101139:	e8 42 06 00 00       	call   80101780 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010113e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101141:	57                   	push   %edi
80101142:	ff 73 14             	push   0x14(%ebx)
80101145:	01 f0                	add    %esi,%eax
80101147:	50                   	push   %eax
80101148:	ff 73 10             	push   0x10(%ebx)
8010114b:	e8 40 0a 00 00       	call   80101b90 <writei>
80101150:	83 c4 20             	add    $0x20,%esp
80101153:	85 c0                	test   %eax,%eax
80101155:	7f a1                	jg     801010f8 <filewrite+0x48>
      iunlock(f->ip);
80101157:	83 ec 0c             	sub    $0xc,%esp
8010115a:	ff 73 10             	push   0x10(%ebx)
8010115d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101160:	e8 fb 06 00 00       	call   80101860 <iunlock>
      end_op();
80101165:	e8 66 1c 00 00       	call   80102dd0 <end_op>
      if(r < 0)
8010116a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010116d:	83 c4 10             	add    $0x10,%esp
80101170:	85 c0                	test   %eax,%eax
80101172:	75 1b                	jne    8010118f <filewrite+0xdf>
        panic("short filewrite");
80101174:	83 ec 0c             	sub    $0xc,%esp
80101177:	68 6f 7f 10 80       	push   $0x80107f6f
8010117c:	e8 ff f1 ff ff       	call   80100380 <panic>
80101181:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
    return i == n ? n : -1;
80101188:	89 f0                	mov    %esi,%eax
8010118a:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
8010118d:	74 05                	je     80101194 <filewrite+0xe4>
8010118f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80101194:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101197:	5b                   	pop    %ebx
80101198:	5e                   	pop    %esi
80101199:	5f                   	pop    %edi
8010119a:	5d                   	pop    %ebp
8010119b:	c3                   	ret    
    return pipewrite(f->pipe, addr, n);
8010119c:	8b 43 0c             	mov    0xc(%ebx),%eax
8010119f:	89 45 08             	mov    %eax,0x8(%ebp)
}
801011a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a5:	5b                   	pop    %ebx
801011a6:	5e                   	pop    %esi
801011a7:	5f                   	pop    %edi
801011a8:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801011a9:	e9 22 24 00 00       	jmp    801035d0 <pipewrite>
  panic("filewrite");
801011ae:	83 ec 0c             	sub    $0xc,%esp
801011b1:	68 75 7f 10 80       	push   $0x80107f75
801011b6:	e8 c5 f1 ff ff       	call   80100380 <panic>
801011bb:	66 90                	xchg   %ax,%ax
801011bd:	66 90                	xchg   %ax,%ax
801011bf:	90                   	nop

801011c0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801011c0:	55                   	push   %ebp
801011c1:	89 c1                	mov    %eax,%ecx
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801011c3:	89 d0                	mov    %edx,%eax
801011c5:	c1 e8 0c             	shr    $0xc,%eax
801011c8:	03 05 cc 25 11 80    	add    0x801125cc,%eax
{
801011ce:	89 e5                	mov    %esp,%ebp
801011d0:	56                   	push   %esi
801011d1:	53                   	push   %ebx
801011d2:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
801011d4:	83 ec 08             	sub    $0x8,%esp
801011d7:	50                   	push   %eax
801011d8:	51                   	push   %ecx
801011d9:	e8 f2 ee ff ff       	call   801000d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
801011de:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
801011e0:	c1 fb 03             	sar    $0x3,%ebx
801011e3:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801011e6:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
801011e8:	83 e1 07             	and    $0x7,%ecx
801011eb:	b8 01 00 00 00       	mov    $0x1,%eax
  if((bp->data[bi/8] & m) == 0)
801011f0:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
  m = 1 << (bi % 8);
801011f6:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
801011f8:	0f b6 4c 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%ecx
801011fd:	85 c1                	test   %eax,%ecx
801011ff:	74 23                	je     80101224 <bfree+0x64>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
80101201:	f7 d0                	not    %eax
  log_write(bp);
80101203:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101206:	21 c8                	and    %ecx,%eax
80101208:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
8010120c:	56                   	push   %esi
8010120d:	e8 2e 1d 00 00       	call   80102f40 <log_write>
  brelse(bp);
80101212:	89 34 24             	mov    %esi,(%esp)
80101215:	e8 d6 ef ff ff       	call   801001f0 <brelse>
}
8010121a:	83 c4 10             	add    $0x10,%esp
8010121d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101220:	5b                   	pop    %ebx
80101221:	5e                   	pop    %esi
80101222:	5d                   	pop    %ebp
80101223:	c3                   	ret    
    panic("freeing free block");
80101224:	83 ec 0c             	sub    $0xc,%esp
80101227:	68 7f 7f 10 80       	push   $0x80107f7f
8010122c:	e8 4f f1 ff ff       	call   80100380 <panic>
80101231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101238:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010123f:	90                   	nop

80101240 <balloc>:
{
80101240:	55                   	push   %ebp
80101241:	89 e5                	mov    %esp,%ebp
80101243:	57                   	push   %edi
80101244:	56                   	push   %esi
80101245:	53                   	push   %ebx
80101246:	83 ec 1c             	sub    $0x1c,%esp
  for(b = 0; b < sb.size; b += BPB){
80101249:	8b 0d b4 25 11 80    	mov    0x801125b4,%ecx
{
8010124f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101252:	85 c9                	test   %ecx,%ecx
80101254:	0f 84 87 00 00 00    	je     801012e1 <balloc+0xa1>
8010125a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101261:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101264:	83 ec 08             	sub    $0x8,%esp
80101267:	89 f0                	mov    %esi,%eax
80101269:	c1 f8 0c             	sar    $0xc,%eax
8010126c:	03 05 cc 25 11 80    	add    0x801125cc,%eax
80101272:	50                   	push   %eax
80101273:	ff 75 d8             	push   -0x28(%ebp)
80101276:	e8 55 ee ff ff       	call   801000d0 <bread>
8010127b:	83 c4 10             	add    $0x10,%esp
8010127e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101281:	a1 b4 25 11 80       	mov    0x801125b4,%eax
80101286:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101289:	31 c0                	xor    %eax,%eax
8010128b:	eb 2f                	jmp    801012bc <balloc+0x7c>
8010128d:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
80101290:	89 c1                	mov    %eax,%ecx
80101292:	bb 01 00 00 00       	mov    $0x1,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101297:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      m = 1 << (bi % 8);
8010129a:	83 e1 07             	and    $0x7,%ecx
8010129d:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010129f:	89 c1                	mov    %eax,%ecx
801012a1:	c1 f9 03             	sar    $0x3,%ecx
801012a4:	0f b6 7c 0a 5c       	movzbl 0x5c(%edx,%ecx,1),%edi
801012a9:	89 fa                	mov    %edi,%edx
801012ab:	85 df                	test   %ebx,%edi
801012ad:	74 41                	je     801012f0 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801012af:	83 c0 01             	add    $0x1,%eax
801012b2:	83 c6 01             	add    $0x1,%esi
801012b5:	3d 00 10 00 00       	cmp    $0x1000,%eax
801012ba:	74 05                	je     801012c1 <balloc+0x81>
801012bc:	39 75 e0             	cmp    %esi,-0x20(%ebp)
801012bf:	77 cf                	ja     80101290 <balloc+0x50>
    brelse(bp);
801012c1:	83 ec 0c             	sub    $0xc,%esp
801012c4:	ff 75 e4             	push   -0x1c(%ebp)
801012c7:	e8 24 ef ff ff       	call   801001f0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
801012cc:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
801012d3:	83 c4 10             	add    $0x10,%esp
801012d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801012d9:	39 05 b4 25 11 80    	cmp    %eax,0x801125b4
801012df:	77 80                	ja     80101261 <balloc+0x21>
  panic("balloc: out of blocks");
801012e1:	83 ec 0c             	sub    $0xc,%esp
801012e4:	68 92 7f 10 80       	push   $0x80107f92
801012e9:	e8 92 f0 ff ff       	call   80100380 <panic>
801012ee:	66 90                	xchg   %ax,%ax
        bp->data[bi/8] |= m;  // Mark block in use.
801012f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
801012f3:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
801012f6:	09 da                	or     %ebx,%edx
801012f8:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
801012fc:	57                   	push   %edi
801012fd:	e8 3e 1c 00 00       	call   80102f40 <log_write>
        brelse(bp);
80101302:	89 3c 24             	mov    %edi,(%esp)
80101305:	e8 e6 ee ff ff       	call   801001f0 <brelse>
  bp = bread(dev, bno);
8010130a:	58                   	pop    %eax
8010130b:	5a                   	pop    %edx
8010130c:	56                   	push   %esi
8010130d:	ff 75 d8             	push   -0x28(%ebp)
80101310:	e8 bb ed ff ff       	call   801000d0 <bread>
  memset(bp->data, 0, BSIZE);
80101315:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
80101318:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
8010131a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010131d:	68 00 02 00 00       	push   $0x200
80101322:	6a 00                	push   $0x0
80101324:	50                   	push   %eax
80101325:	e8 f6 3a 00 00       	call   80104e20 <memset>
  log_write(bp);
8010132a:	89 1c 24             	mov    %ebx,(%esp)
8010132d:	e8 0e 1c 00 00       	call   80102f40 <log_write>
  brelse(bp);
80101332:	89 1c 24             	mov    %ebx,(%esp)
80101335:	e8 b6 ee ff ff       	call   801001f0 <brelse>
}
8010133a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010133d:	89 f0                	mov    %esi,%eax
8010133f:	5b                   	pop    %ebx
80101340:	5e                   	pop    %esi
80101341:	5f                   	pop    %edi
80101342:	5d                   	pop    %ebp
80101343:	c3                   	ret    
80101344:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010134b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010134f:	90                   	nop

80101350 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101350:	55                   	push   %ebp
80101351:	89 e5                	mov    %esp,%ebp
80101353:	57                   	push   %edi
80101354:	89 c7                	mov    %eax,%edi
80101356:	56                   	push   %esi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80101357:	31 f6                	xor    %esi,%esi
{
80101359:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010135a:	bb 94 09 11 80       	mov    $0x80110994,%ebx
{
8010135f:	83 ec 28             	sub    $0x28,%esp
80101362:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101365:	68 60 09 11 80       	push   $0x80110960
8010136a:	e8 f1 39 00 00       	call   80104d60 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010136f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
80101372:	83 c4 10             	add    $0x10,%esp
80101375:	eb 1b                	jmp    80101392 <iget+0x42>
80101377:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010137e:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101380:	39 3b                	cmp    %edi,(%ebx)
80101382:	74 6c                	je     801013f0 <iget+0xa0>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101384:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010138a:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
80101390:	73 26                	jae    801013b8 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101392:	8b 43 08             	mov    0x8(%ebx),%eax
80101395:	85 c0                	test   %eax,%eax
80101397:	7f e7                	jg     80101380 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101399:	85 f6                	test   %esi,%esi
8010139b:	75 e7                	jne    80101384 <iget+0x34>
8010139d:	85 c0                	test   %eax,%eax
8010139f:	75 76                	jne    80101417 <iget+0xc7>
801013a1:	89 de                	mov    %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801013a3:	81 c3 90 00 00 00    	add    $0x90,%ebx
801013a9:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
801013af:	72 e1                	jb     80101392 <iget+0x42>
801013b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801013b8:	85 f6                	test   %esi,%esi
801013ba:	74 79                	je     80101435 <iget+0xe5>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
801013bc:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
801013bf:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801013c1:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
801013c4:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801013cb:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801013d2:	68 60 09 11 80       	push   $0x80110960
801013d7:	e8 24 39 00 00       	call   80104d00 <release>

  return ip;
801013dc:	83 c4 10             	add    $0x10,%esp
}
801013df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013e2:	89 f0                	mov    %esi,%eax
801013e4:	5b                   	pop    %ebx
801013e5:	5e                   	pop    %esi
801013e6:	5f                   	pop    %edi
801013e7:	5d                   	pop    %ebp
801013e8:	c3                   	ret    
801013e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801013f0:	39 53 04             	cmp    %edx,0x4(%ebx)
801013f3:	75 8f                	jne    80101384 <iget+0x34>
      release(&icache.lock);
801013f5:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
801013f8:	83 c0 01             	add    $0x1,%eax
      return ip;
801013fb:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
801013fd:	68 60 09 11 80       	push   $0x80110960
      ip->ref++;
80101402:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101405:	e8 f6 38 00 00       	call   80104d00 <release>
      return ip;
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101410:	89 f0                	mov    %esi,%eax
80101412:	5b                   	pop    %ebx
80101413:	5e                   	pop    %esi
80101414:	5f                   	pop    %edi
80101415:	5d                   	pop    %ebp
80101416:	c3                   	ret    
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101417:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010141d:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
80101423:	73 10                	jae    80101435 <iget+0xe5>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101425:	8b 43 08             	mov    0x8(%ebx),%eax
80101428:	85 c0                	test   %eax,%eax
8010142a:	0f 8f 50 ff ff ff    	jg     80101380 <iget+0x30>
80101430:	e9 68 ff ff ff       	jmp    8010139d <iget+0x4d>
    panic("iget: no inodes");
80101435:	83 ec 0c             	sub    $0xc,%esp
80101438:	68 a8 7f 10 80       	push   $0x80107fa8
8010143d:	e8 3e ef ff ff       	call   80100380 <panic>
80101442:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101450 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101450:	55                   	push   %ebp
80101451:	89 e5                	mov    %esp,%ebp
80101453:	57                   	push   %edi
80101454:	56                   	push   %esi
80101455:	89 c6                	mov    %eax,%esi
80101457:	53                   	push   %ebx
80101458:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010145b:	83 fa 0b             	cmp    $0xb,%edx
8010145e:	0f 86 8c 00 00 00    	jbe    801014f0 <bmap+0xa0>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101464:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
80101467:	83 fb 7f             	cmp    $0x7f,%ebx
8010146a:	0f 87 a2 00 00 00    	ja     80101512 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101470:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101476:	85 c0                	test   %eax,%eax
80101478:	74 5e                	je     801014d8 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
8010147a:	83 ec 08             	sub    $0x8,%esp
8010147d:	50                   	push   %eax
8010147e:	ff 36                	push   (%esi)
80101480:	e8 4b ec ff ff       	call   801000d0 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80101485:	83 c4 10             	add    $0x10,%esp
80101488:	8d 5c 98 5c          	lea    0x5c(%eax,%ebx,4),%ebx
    bp = bread(ip->dev, addr);
8010148c:	89 c2                	mov    %eax,%edx
    if((addr = a[bn]) == 0){
8010148e:	8b 3b                	mov    (%ebx),%edi
80101490:	85 ff                	test   %edi,%edi
80101492:	74 1c                	je     801014b0 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
80101494:	83 ec 0c             	sub    $0xc,%esp
80101497:	52                   	push   %edx
80101498:	e8 53 ed ff ff       	call   801001f0 <brelse>
8010149d:	83 c4 10             	add    $0x10,%esp
    return addr;
  }

  panic("bmap: out of range");
}
801014a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014a3:	89 f8                	mov    %edi,%eax
801014a5:	5b                   	pop    %ebx
801014a6:	5e                   	pop    %esi
801014a7:	5f                   	pop    %edi
801014a8:	5d                   	pop    %ebp
801014a9:	c3                   	ret    
801014aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801014b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      a[bn] = addr = balloc(ip->dev);
801014b3:	8b 06                	mov    (%esi),%eax
801014b5:	e8 86 fd ff ff       	call   80101240 <balloc>
      log_write(bp);
801014ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014bd:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
801014c0:	89 03                	mov    %eax,(%ebx)
801014c2:	89 c7                	mov    %eax,%edi
      log_write(bp);
801014c4:	52                   	push   %edx
801014c5:	e8 76 1a 00 00       	call   80102f40 <log_write>
801014ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014cd:	83 c4 10             	add    $0x10,%esp
801014d0:	eb c2                	jmp    80101494 <bmap+0x44>
801014d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801014d8:	8b 06                	mov    (%esi),%eax
801014da:	e8 61 fd ff ff       	call   80101240 <balloc>
801014df:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
801014e5:	eb 93                	jmp    8010147a <bmap+0x2a>
801014e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801014ee:	66 90                	xchg   %ax,%ax
    if((addr = ip->addrs[bn]) == 0)
801014f0:	8d 5a 14             	lea    0x14(%edx),%ebx
801014f3:	8b 7c 98 0c          	mov    0xc(%eax,%ebx,4),%edi
801014f7:	85 ff                	test   %edi,%edi
801014f9:	75 a5                	jne    801014a0 <bmap+0x50>
      ip->addrs[bn] = addr = balloc(ip->dev);
801014fb:	8b 00                	mov    (%eax),%eax
801014fd:	e8 3e fd ff ff       	call   80101240 <balloc>
80101502:	89 44 9e 0c          	mov    %eax,0xc(%esi,%ebx,4)
80101506:	89 c7                	mov    %eax,%edi
}
80101508:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010150b:	5b                   	pop    %ebx
8010150c:	89 f8                	mov    %edi,%eax
8010150e:	5e                   	pop    %esi
8010150f:	5f                   	pop    %edi
80101510:	5d                   	pop    %ebp
80101511:	c3                   	ret    
  panic("bmap: out of range");
80101512:	83 ec 0c             	sub    $0xc,%esp
80101515:	68 b8 7f 10 80       	push   $0x80107fb8
8010151a:	e8 61 ee ff ff       	call   80100380 <panic>
8010151f:	90                   	nop

80101520 <readsb>:
{
80101520:	55                   	push   %ebp
80101521:	89 e5                	mov    %esp,%ebp
80101523:	56                   	push   %esi
80101524:	53                   	push   %ebx
80101525:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101528:	83 ec 08             	sub    $0x8,%esp
8010152b:	6a 01                	push   $0x1
8010152d:	ff 75 08             	push   0x8(%ebp)
80101530:	e8 9b eb ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101535:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
80101538:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010153a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010153d:	6a 1c                	push   $0x1c
8010153f:	50                   	push   %eax
80101540:	56                   	push   %esi
80101541:	e8 7a 39 00 00       	call   80104ec0 <memmove>
  brelse(bp);
80101546:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101549:	83 c4 10             	add    $0x10,%esp
}
8010154c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010154f:	5b                   	pop    %ebx
80101550:	5e                   	pop    %esi
80101551:	5d                   	pop    %ebp
  brelse(bp);
80101552:	e9 99 ec ff ff       	jmp    801001f0 <brelse>
80101557:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010155e:	66 90                	xchg   %ax,%ax

80101560 <iinit>:
{
80101560:	55                   	push   %ebp
80101561:	89 e5                	mov    %esp,%ebp
80101563:	53                   	push   %ebx
80101564:	bb a0 09 11 80       	mov    $0x801109a0,%ebx
80101569:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010156c:	68 cb 7f 10 80       	push   $0x80107fcb
80101571:	68 60 09 11 80       	push   $0x80110960
80101576:	e8 15 36 00 00       	call   80104b90 <initlock>
  for(i = 0; i < NINODE; i++) {
8010157b:	83 c4 10             	add    $0x10,%esp
8010157e:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
80101580:	83 ec 08             	sub    $0x8,%esp
80101583:	68 d2 7f 10 80       	push   $0x80107fd2
80101588:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
80101589:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
8010158f:	e8 cc 34 00 00       	call   80104a60 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101594:	83 c4 10             	add    $0x10,%esp
80101597:	81 fb c0 25 11 80    	cmp    $0x801125c0,%ebx
8010159d:	75 e1                	jne    80101580 <iinit+0x20>
  bp = bread(dev, 1);
8010159f:	83 ec 08             	sub    $0x8,%esp
801015a2:	6a 01                	push   $0x1
801015a4:	ff 75 08             	push   0x8(%ebp)
801015a7:	e8 24 eb ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801015ac:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801015af:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801015b1:	8d 40 5c             	lea    0x5c(%eax),%eax
801015b4:	6a 1c                	push   $0x1c
801015b6:	50                   	push   %eax
801015b7:	68 b4 25 11 80       	push   $0x801125b4
801015bc:	e8 ff 38 00 00       	call   80104ec0 <memmove>
  brelse(bp);
801015c1:	89 1c 24             	mov    %ebx,(%esp)
801015c4:	e8 27 ec ff ff       	call   801001f0 <brelse>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801015c9:	ff 35 cc 25 11 80    	push   0x801125cc
801015cf:	ff 35 c8 25 11 80    	push   0x801125c8
801015d5:	ff 35 c4 25 11 80    	push   0x801125c4
801015db:	ff 35 c0 25 11 80    	push   0x801125c0
801015e1:	ff 35 bc 25 11 80    	push   0x801125bc
801015e7:	ff 35 b8 25 11 80    	push   0x801125b8
801015ed:	ff 35 b4 25 11 80    	push   0x801125b4
801015f3:	68 38 80 10 80       	push   $0x80108038
801015f8:	e8 a3 f0 ff ff       	call   801006a0 <cprintf>
}
801015fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101600:	83 c4 30             	add    $0x30,%esp
80101603:	c9                   	leave  
80101604:	c3                   	ret    
80101605:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010160c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101610 <ialloc>:
{
80101610:	55                   	push   %ebp
80101611:	89 e5                	mov    %esp,%ebp
80101613:	57                   	push   %edi
80101614:	56                   	push   %esi
80101615:	53                   	push   %ebx
80101616:	83 ec 1c             	sub    $0x1c,%esp
80101619:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010161c:	83 3d bc 25 11 80 01 	cmpl   $0x1,0x801125bc
{
80101623:	8b 75 08             	mov    0x8(%ebp),%esi
80101626:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101629:	0f 86 91 00 00 00    	jbe    801016c0 <ialloc+0xb0>
8010162f:	bf 01 00 00 00       	mov    $0x1,%edi
80101634:	eb 21                	jmp    80101657 <ialloc+0x47>
80101636:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010163d:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101640:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101643:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101646:	53                   	push   %ebx
80101647:	e8 a4 eb ff ff       	call   801001f0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010164c:	83 c4 10             	add    $0x10,%esp
8010164f:	3b 3d bc 25 11 80    	cmp    0x801125bc,%edi
80101655:	73 69                	jae    801016c0 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101657:	89 f8                	mov    %edi,%eax
80101659:	83 ec 08             	sub    $0x8,%esp
8010165c:	c1 e8 03             	shr    $0x3,%eax
8010165f:	03 05 c8 25 11 80    	add    0x801125c8,%eax
80101665:	50                   	push   %eax
80101666:	56                   	push   %esi
80101667:	e8 64 ea ff ff       	call   801000d0 <bread>
    if(dip->type == 0){  // a free inode
8010166c:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
8010166f:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
80101671:	89 f8                	mov    %edi,%eax
80101673:	83 e0 07             	and    $0x7,%eax
80101676:	c1 e0 06             	shl    $0x6,%eax
80101679:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010167d:	66 83 39 00          	cmpw   $0x0,(%ecx)
80101681:	75 bd                	jne    80101640 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
80101683:	83 ec 04             	sub    $0x4,%esp
80101686:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101689:	6a 40                	push   $0x40
8010168b:	6a 00                	push   $0x0
8010168d:	51                   	push   %ecx
8010168e:	e8 8d 37 00 00       	call   80104e20 <memset>
      dip->type = type;
80101693:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80101697:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010169a:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
8010169d:	89 1c 24             	mov    %ebx,(%esp)
801016a0:	e8 9b 18 00 00       	call   80102f40 <log_write>
      brelse(bp);
801016a5:	89 1c 24             	mov    %ebx,(%esp)
801016a8:	e8 43 eb ff ff       	call   801001f0 <brelse>
      return iget(dev, inum);
801016ad:	83 c4 10             	add    $0x10,%esp
}
801016b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
801016b3:	89 fa                	mov    %edi,%edx
}
801016b5:	5b                   	pop    %ebx
      return iget(dev, inum);
801016b6:	89 f0                	mov    %esi,%eax
}
801016b8:	5e                   	pop    %esi
801016b9:	5f                   	pop    %edi
801016ba:	5d                   	pop    %ebp
      return iget(dev, inum);
801016bb:	e9 90 fc ff ff       	jmp    80101350 <iget>
  panic("ialloc: no inodes");
801016c0:	83 ec 0c             	sub    $0xc,%esp
801016c3:	68 d8 7f 10 80       	push   $0x80107fd8
801016c8:	e8 b3 ec ff ff       	call   80100380 <panic>
801016cd:	8d 76 00             	lea    0x0(%esi),%esi

801016d0 <iupdate>:
{
801016d0:	55                   	push   %ebp
801016d1:	89 e5                	mov    %esp,%ebp
801016d3:	56                   	push   %esi
801016d4:	53                   	push   %ebx
801016d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016d8:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016db:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016de:	83 ec 08             	sub    $0x8,%esp
801016e1:	c1 e8 03             	shr    $0x3,%eax
801016e4:	03 05 c8 25 11 80    	add    0x801125c8,%eax
801016ea:	50                   	push   %eax
801016eb:	ff 73 a4             	push   -0x5c(%ebx)
801016ee:	e8 dd e9 ff ff       	call   801000d0 <bread>
  dip->type = ip->type;
801016f3:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016f7:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016fa:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016fc:	8b 43 a8             	mov    -0x58(%ebx),%eax
801016ff:	83 e0 07             	and    $0x7,%eax
80101702:	c1 e0 06             	shl    $0x6,%eax
80101705:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101709:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010170c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101710:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101713:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101717:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010171b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010171f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101723:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101727:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010172a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010172d:	6a 34                	push   $0x34
8010172f:	53                   	push   %ebx
80101730:	50                   	push   %eax
80101731:	e8 8a 37 00 00       	call   80104ec0 <memmove>
  log_write(bp);
80101736:	89 34 24             	mov    %esi,(%esp)
80101739:	e8 02 18 00 00       	call   80102f40 <log_write>
  brelse(bp);
8010173e:	89 75 08             	mov    %esi,0x8(%ebp)
80101741:	83 c4 10             	add    $0x10,%esp
}
80101744:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101747:	5b                   	pop    %ebx
80101748:	5e                   	pop    %esi
80101749:	5d                   	pop    %ebp
  brelse(bp);
8010174a:	e9 a1 ea ff ff       	jmp    801001f0 <brelse>
8010174f:	90                   	nop

80101750 <idup>:
{
80101750:	55                   	push   %ebp
80101751:	89 e5                	mov    %esp,%ebp
80101753:	53                   	push   %ebx
80101754:	83 ec 10             	sub    $0x10,%esp
80101757:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010175a:	68 60 09 11 80       	push   $0x80110960
8010175f:	e8 fc 35 00 00       	call   80104d60 <acquire>
  ip->ref++;
80101764:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101768:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
8010176f:	e8 8c 35 00 00       	call   80104d00 <release>
}
80101774:	89 d8                	mov    %ebx,%eax
80101776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101779:	c9                   	leave  
8010177a:	c3                   	ret    
8010177b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010177f:	90                   	nop

80101780 <ilock>:
{
80101780:	55                   	push   %ebp
80101781:	89 e5                	mov    %esp,%ebp
80101783:	56                   	push   %esi
80101784:	53                   	push   %ebx
80101785:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101788:	85 db                	test   %ebx,%ebx
8010178a:	0f 84 b7 00 00 00    	je     80101847 <ilock+0xc7>
80101790:	8b 53 08             	mov    0x8(%ebx),%edx
80101793:	85 d2                	test   %edx,%edx
80101795:	0f 8e ac 00 00 00    	jle    80101847 <ilock+0xc7>
  acquiresleep(&ip->lock);
8010179b:	83 ec 0c             	sub    $0xc,%esp
8010179e:	8d 43 0c             	lea    0xc(%ebx),%eax
801017a1:	50                   	push   %eax
801017a2:	e8 f9 32 00 00       	call   80104aa0 <acquiresleep>
  if(ip->valid == 0){
801017a7:	8b 43 4c             	mov    0x4c(%ebx),%eax
801017aa:	83 c4 10             	add    $0x10,%esp
801017ad:	85 c0                	test   %eax,%eax
801017af:	74 0f                	je     801017c0 <ilock+0x40>
}
801017b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801017b4:	5b                   	pop    %ebx
801017b5:	5e                   	pop    %esi
801017b6:	5d                   	pop    %ebp
801017b7:	c3                   	ret    
801017b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801017bf:	90                   	nop
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017c0:	8b 43 04             	mov    0x4(%ebx),%eax
801017c3:	83 ec 08             	sub    $0x8,%esp
801017c6:	c1 e8 03             	shr    $0x3,%eax
801017c9:	03 05 c8 25 11 80    	add    0x801125c8,%eax
801017cf:	50                   	push   %eax
801017d0:	ff 33                	push   (%ebx)
801017d2:	e8 f9 e8 ff ff       	call   801000d0 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017d7:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017da:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801017dc:	8b 43 04             	mov    0x4(%ebx),%eax
801017df:	83 e0 07             	and    $0x7,%eax
801017e2:	c1 e0 06             	shl    $0x6,%eax
801017e5:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801017e9:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017ec:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
801017ef:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801017f3:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
801017f7:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801017fb:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
801017ff:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101803:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101807:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010180b:	8b 50 fc             	mov    -0x4(%eax),%edx
8010180e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101811:	6a 34                	push   $0x34
80101813:	50                   	push   %eax
80101814:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101817:	50                   	push   %eax
80101818:	e8 a3 36 00 00       	call   80104ec0 <memmove>
    brelse(bp);
8010181d:	89 34 24             	mov    %esi,(%esp)
80101820:	e8 cb e9 ff ff       	call   801001f0 <brelse>
    if(ip->type == 0)
80101825:	83 c4 10             	add    $0x10,%esp
80101828:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
8010182d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101834:	0f 85 77 ff ff ff    	jne    801017b1 <ilock+0x31>
      panic("ilock: no type");
8010183a:	83 ec 0c             	sub    $0xc,%esp
8010183d:	68 f0 7f 10 80       	push   $0x80107ff0
80101842:	e8 39 eb ff ff       	call   80100380 <panic>
    panic("ilock");
80101847:	83 ec 0c             	sub    $0xc,%esp
8010184a:	68 ea 7f 10 80       	push   $0x80107fea
8010184f:	e8 2c eb ff ff       	call   80100380 <panic>
80101854:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010185b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010185f:	90                   	nop

80101860 <iunlock>:
{
80101860:	55                   	push   %ebp
80101861:	89 e5                	mov    %esp,%ebp
80101863:	56                   	push   %esi
80101864:	53                   	push   %ebx
80101865:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101868:	85 db                	test   %ebx,%ebx
8010186a:	74 28                	je     80101894 <iunlock+0x34>
8010186c:	83 ec 0c             	sub    $0xc,%esp
8010186f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101872:	56                   	push   %esi
80101873:	e8 c8 32 00 00       	call   80104b40 <holdingsleep>
80101878:	83 c4 10             	add    $0x10,%esp
8010187b:	85 c0                	test   %eax,%eax
8010187d:	74 15                	je     80101894 <iunlock+0x34>
8010187f:	8b 43 08             	mov    0x8(%ebx),%eax
80101882:	85 c0                	test   %eax,%eax
80101884:	7e 0e                	jle    80101894 <iunlock+0x34>
  releasesleep(&ip->lock);
80101886:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101889:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010188c:	5b                   	pop    %ebx
8010188d:	5e                   	pop    %esi
8010188e:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
8010188f:	e9 6c 32 00 00       	jmp    80104b00 <releasesleep>
    panic("iunlock");
80101894:	83 ec 0c             	sub    $0xc,%esp
80101897:	68 ff 7f 10 80       	push   $0x80107fff
8010189c:	e8 df ea ff ff       	call   80100380 <panic>
801018a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018af:	90                   	nop

801018b0 <iput>:
{
801018b0:	55                   	push   %ebp
801018b1:	89 e5                	mov    %esp,%ebp
801018b3:	57                   	push   %edi
801018b4:	56                   	push   %esi
801018b5:	53                   	push   %ebx
801018b6:	83 ec 28             	sub    $0x28,%esp
801018b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801018bc:	8d 7b 0c             	lea    0xc(%ebx),%edi
801018bf:	57                   	push   %edi
801018c0:	e8 db 31 00 00       	call   80104aa0 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801018c5:	8b 53 4c             	mov    0x4c(%ebx),%edx
801018c8:	83 c4 10             	add    $0x10,%esp
801018cb:	85 d2                	test   %edx,%edx
801018cd:	74 07                	je     801018d6 <iput+0x26>
801018cf:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801018d4:	74 32                	je     80101908 <iput+0x58>
  releasesleep(&ip->lock);
801018d6:	83 ec 0c             	sub    $0xc,%esp
801018d9:	57                   	push   %edi
801018da:	e8 21 32 00 00       	call   80104b00 <releasesleep>
  acquire(&icache.lock);
801018df:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
801018e6:	e8 75 34 00 00       	call   80104d60 <acquire>
  ip->ref--;
801018eb:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
801018ef:	83 c4 10             	add    $0x10,%esp
801018f2:	c7 45 08 60 09 11 80 	movl   $0x80110960,0x8(%ebp)
}
801018f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018fc:	5b                   	pop    %ebx
801018fd:	5e                   	pop    %esi
801018fe:	5f                   	pop    %edi
801018ff:	5d                   	pop    %ebp
  release(&icache.lock);
80101900:	e9 fb 33 00 00       	jmp    80104d00 <release>
80101905:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101908:	83 ec 0c             	sub    $0xc,%esp
8010190b:	68 60 09 11 80       	push   $0x80110960
80101910:	e8 4b 34 00 00       	call   80104d60 <acquire>
    int r = ip->ref;
80101915:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101918:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
8010191f:	e8 dc 33 00 00       	call   80104d00 <release>
    if(r == 1){
80101924:	83 c4 10             	add    $0x10,%esp
80101927:	83 fe 01             	cmp    $0x1,%esi
8010192a:	75 aa                	jne    801018d6 <iput+0x26>
8010192c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101932:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101935:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101938:	89 cf                	mov    %ecx,%edi
8010193a:	eb 0b                	jmp    80101947 <iput+0x97>
8010193c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101940:	83 c6 04             	add    $0x4,%esi
80101943:	39 fe                	cmp    %edi,%esi
80101945:	74 19                	je     80101960 <iput+0xb0>
    if(ip->addrs[i]){
80101947:	8b 16                	mov    (%esi),%edx
80101949:	85 d2                	test   %edx,%edx
8010194b:	74 f3                	je     80101940 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
8010194d:	8b 03                	mov    (%ebx),%eax
8010194f:	e8 6c f8 ff ff       	call   801011c0 <bfree>
      ip->addrs[i] = 0;
80101954:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010195a:	eb e4                	jmp    80101940 <iput+0x90>
8010195c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101960:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101966:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101969:	85 c0                	test   %eax,%eax
8010196b:	75 2d                	jne    8010199a <iput+0xea>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
8010196d:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101970:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101977:	53                   	push   %ebx
80101978:	e8 53 fd ff ff       	call   801016d0 <iupdate>
      ip->type = 0;
8010197d:	31 c0                	xor    %eax,%eax
8010197f:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101983:	89 1c 24             	mov    %ebx,(%esp)
80101986:	e8 45 fd ff ff       	call   801016d0 <iupdate>
      ip->valid = 0;
8010198b:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101992:	83 c4 10             	add    $0x10,%esp
80101995:	e9 3c ff ff ff       	jmp    801018d6 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
8010199a:	83 ec 08             	sub    $0x8,%esp
8010199d:	50                   	push   %eax
8010199e:	ff 33                	push   (%ebx)
801019a0:	e8 2b e7 ff ff       	call   801000d0 <bread>
801019a5:	89 7d e0             	mov    %edi,-0x20(%ebp)
801019a8:	83 c4 10             	add    $0x10,%esp
801019ab:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
801019b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
801019b4:	8d 70 5c             	lea    0x5c(%eax),%esi
801019b7:	89 cf                	mov    %ecx,%edi
801019b9:	eb 0c                	jmp    801019c7 <iput+0x117>
801019bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801019bf:	90                   	nop
801019c0:	83 c6 04             	add    $0x4,%esi
801019c3:	39 f7                	cmp    %esi,%edi
801019c5:	74 0f                	je     801019d6 <iput+0x126>
      if(a[j])
801019c7:	8b 16                	mov    (%esi),%edx
801019c9:	85 d2                	test   %edx,%edx
801019cb:	74 f3                	je     801019c0 <iput+0x110>
        bfree(ip->dev, a[j]);
801019cd:	8b 03                	mov    (%ebx),%eax
801019cf:	e8 ec f7 ff ff       	call   801011c0 <bfree>
801019d4:	eb ea                	jmp    801019c0 <iput+0x110>
    brelse(bp);
801019d6:	83 ec 0c             	sub    $0xc,%esp
801019d9:	ff 75 e4             	push   -0x1c(%ebp)
801019dc:	8b 7d e0             	mov    -0x20(%ebp),%edi
801019df:	e8 0c e8 ff ff       	call   801001f0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801019e4:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
801019ea:	8b 03                	mov    (%ebx),%eax
801019ec:	e8 cf f7 ff ff       	call   801011c0 <bfree>
    ip->addrs[NDIRECT] = 0;
801019f1:	83 c4 10             	add    $0x10,%esp
801019f4:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
801019fb:	00 00 00 
801019fe:	e9 6a ff ff ff       	jmp    8010196d <iput+0xbd>
80101a03:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101a0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101a10 <iunlockput>:
{
80101a10:	55                   	push   %ebp
80101a11:	89 e5                	mov    %esp,%ebp
80101a13:	56                   	push   %esi
80101a14:	53                   	push   %ebx
80101a15:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a18:	85 db                	test   %ebx,%ebx
80101a1a:	74 34                	je     80101a50 <iunlockput+0x40>
80101a1c:	83 ec 0c             	sub    $0xc,%esp
80101a1f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101a22:	56                   	push   %esi
80101a23:	e8 18 31 00 00       	call   80104b40 <holdingsleep>
80101a28:	83 c4 10             	add    $0x10,%esp
80101a2b:	85 c0                	test   %eax,%eax
80101a2d:	74 21                	je     80101a50 <iunlockput+0x40>
80101a2f:	8b 43 08             	mov    0x8(%ebx),%eax
80101a32:	85 c0                	test   %eax,%eax
80101a34:	7e 1a                	jle    80101a50 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101a36:	83 ec 0c             	sub    $0xc,%esp
80101a39:	56                   	push   %esi
80101a3a:	e8 c1 30 00 00       	call   80104b00 <releasesleep>
  iput(ip);
80101a3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101a42:	83 c4 10             	add    $0x10,%esp
}
80101a45:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101a48:	5b                   	pop    %ebx
80101a49:	5e                   	pop    %esi
80101a4a:	5d                   	pop    %ebp
  iput(ip);
80101a4b:	e9 60 fe ff ff       	jmp    801018b0 <iput>
    panic("iunlock");
80101a50:	83 ec 0c             	sub    $0xc,%esp
80101a53:	68 ff 7f 10 80       	push   $0x80107fff
80101a58:	e8 23 e9 ff ff       	call   80100380 <panic>
80101a5d:	8d 76 00             	lea    0x0(%esi),%esi

80101a60 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101a60:	55                   	push   %ebp
80101a61:	89 e5                	mov    %esp,%ebp
80101a63:	8b 55 08             	mov    0x8(%ebp),%edx
80101a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101a69:	8b 0a                	mov    (%edx),%ecx
80101a6b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101a6e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101a71:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101a74:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101a78:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101a7b:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101a7f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101a83:	8b 52 58             	mov    0x58(%edx),%edx
80101a86:	89 50 10             	mov    %edx,0x10(%eax)
}
80101a89:	5d                   	pop    %ebp
80101a8a:	c3                   	ret    
80101a8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101a8f:	90                   	nop

80101a90 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101a90:	55                   	push   %ebp
80101a91:	89 e5                	mov    %esp,%ebp
80101a93:	57                   	push   %edi
80101a94:	56                   	push   %esi
80101a95:	53                   	push   %ebx
80101a96:	83 ec 1c             	sub    $0x1c,%esp
80101a99:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	8b 75 10             	mov    0x10(%ebp),%esi
80101aa2:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101aa5:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101aa8:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101aad:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101ab0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101ab3:	0f 84 a7 00 00 00    	je     80101b60 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101ab9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101abc:	8b 40 58             	mov    0x58(%eax),%eax
80101abf:	39 c6                	cmp    %eax,%esi
80101ac1:	0f 87 ba 00 00 00    	ja     80101b81 <readi+0xf1>
80101ac7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101aca:	31 c9                	xor    %ecx,%ecx
80101acc:	89 da                	mov    %ebx,%edx
80101ace:	01 f2                	add    %esi,%edx
80101ad0:	0f 92 c1             	setb   %cl
80101ad3:	89 cf                	mov    %ecx,%edi
80101ad5:	0f 82 a6 00 00 00    	jb     80101b81 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101adb:	89 c1                	mov    %eax,%ecx
80101add:	29 f1                	sub    %esi,%ecx
80101adf:	39 d0                	cmp    %edx,%eax
80101ae1:	0f 43 cb             	cmovae %ebx,%ecx
80101ae4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ae7:	85 c9                	test   %ecx,%ecx
80101ae9:	74 67                	je     80101b52 <readi+0xc2>
80101aeb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101aef:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101af0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101af3:	89 f2                	mov    %esi,%edx
80101af5:	c1 ea 09             	shr    $0x9,%edx
80101af8:	89 d8                	mov    %ebx,%eax
80101afa:	e8 51 f9 ff ff       	call   80101450 <bmap>
80101aff:	83 ec 08             	sub    $0x8,%esp
80101b02:	50                   	push   %eax
80101b03:	ff 33                	push   (%ebx)
80101b05:	e8 c6 e5 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101b0a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101b0d:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101b12:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101b14:	89 f0                	mov    %esi,%eax
80101b16:	25 ff 01 00 00       	and    $0x1ff,%eax
80101b1b:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101b1d:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101b20:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101b22:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101b26:	39 d9                	cmp    %ebx,%ecx
80101b28:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101b2b:	83 c4 0c             	add    $0xc,%esp
80101b2e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101b2f:	01 df                	add    %ebx,%edi
80101b31:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101b33:	50                   	push   %eax
80101b34:	ff 75 e0             	push   -0x20(%ebp)
80101b37:	e8 84 33 00 00       	call   80104ec0 <memmove>
    brelse(bp);
80101b3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101b3f:	89 14 24             	mov    %edx,(%esp)
80101b42:	e8 a9 e6 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101b47:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101b4a:	83 c4 10             	add    $0x10,%esp
80101b4d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101b50:	77 9e                	ja     80101af0 <readi+0x60>
  }
  return n;
80101b52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b58:	5b                   	pop    %ebx
80101b59:	5e                   	pop    %esi
80101b5a:	5f                   	pop    %edi
80101b5b:	5d                   	pop    %ebp
80101b5c:	c3                   	ret    
80101b5d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101b60:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101b64:	66 83 f8 09          	cmp    $0x9,%ax
80101b68:	77 17                	ja     80101b81 <readi+0xf1>
80101b6a:	8b 04 c5 00 09 11 80 	mov    -0x7feef700(,%eax,8),%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 0c                	je     80101b81 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101b75:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b7b:	5b                   	pop    %ebx
80101b7c:	5e                   	pop    %esi
80101b7d:	5f                   	pop    %edi
80101b7e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101b7f:	ff e0                	jmp    *%eax
      return -1;
80101b81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b86:	eb cd                	jmp    80101b55 <readi+0xc5>
80101b88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b8f:	90                   	nop

80101b90 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101b90:	55                   	push   %ebp
80101b91:	89 e5                	mov    %esp,%ebp
80101b93:	57                   	push   %edi
80101b94:	56                   	push   %esi
80101b95:	53                   	push   %ebx
80101b96:	83 ec 1c             	sub    $0x1c,%esp
80101b99:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9c:	8b 75 0c             	mov    0xc(%ebp),%esi
80101b9f:	8b 55 14             	mov    0x14(%ebp),%edx
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ba2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101ba7:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101baa:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101bad:	8b 75 10             	mov    0x10(%ebp),%esi
80101bb0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(ip->type == T_DEV){
80101bb3:	0f 84 b7 00 00 00    	je     80101c70 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101bb9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bbc:	3b 70 58             	cmp    0x58(%eax),%esi
80101bbf:	0f 87 e7 00 00 00    	ja     80101cac <writei+0x11c>
80101bc5:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101bc8:	31 d2                	xor    %edx,%edx
80101bca:	89 f8                	mov    %edi,%eax
80101bcc:	01 f0                	add    %esi,%eax
80101bce:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101bd1:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101bd6:	0f 87 d0 00 00 00    	ja     80101cac <writei+0x11c>
80101bdc:	85 d2                	test   %edx,%edx
80101bde:	0f 85 c8 00 00 00    	jne    80101cac <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101be4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101beb:	85 ff                	test   %edi,%edi
80101bed:	74 72                	je     80101c61 <writei+0xd1>
80101bef:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101bf0:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101bf3:	89 f2                	mov    %esi,%edx
80101bf5:	c1 ea 09             	shr    $0x9,%edx
80101bf8:	89 f8                	mov    %edi,%eax
80101bfa:	e8 51 f8 ff ff       	call   80101450 <bmap>
80101bff:	83 ec 08             	sub    $0x8,%esp
80101c02:	50                   	push   %eax
80101c03:	ff 37                	push   (%edi)
80101c05:	e8 c6 e4 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101c0a:	b9 00 02 00 00       	mov    $0x200,%ecx
80101c0f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101c12:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c15:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101c17:	89 f0                	mov    %esi,%eax
80101c19:	25 ff 01 00 00       	and    $0x1ff,%eax
80101c1e:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101c20:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101c24:	39 d9                	cmp    %ebx,%ecx
80101c26:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101c29:	83 c4 0c             	add    $0xc,%esp
80101c2c:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101c2d:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101c2f:	ff 75 dc             	push   -0x24(%ebp)
80101c32:	50                   	push   %eax
80101c33:	e8 88 32 00 00       	call   80104ec0 <memmove>
    log_write(bp);
80101c38:	89 3c 24             	mov    %edi,(%esp)
80101c3b:	e8 00 13 00 00       	call   80102f40 <log_write>
    brelse(bp);
80101c40:	89 3c 24             	mov    %edi,(%esp)
80101c43:	e8 a8 e5 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101c48:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101c4b:	83 c4 10             	add    $0x10,%esp
80101c4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c51:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101c54:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101c57:	77 97                	ja     80101bf0 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101c59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101c5c:	3b 70 58             	cmp    0x58(%eax),%esi
80101c5f:	77 37                	ja     80101c98 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101c61:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c67:	5b                   	pop    %ebx
80101c68:	5e                   	pop    %esi
80101c69:	5f                   	pop    %edi
80101c6a:	5d                   	pop    %ebp
80101c6b:	c3                   	ret    
80101c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101c70:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101c74:	66 83 f8 09          	cmp    $0x9,%ax
80101c78:	77 32                	ja     80101cac <writei+0x11c>
80101c7a:	8b 04 c5 04 09 11 80 	mov    -0x7feef6fc(,%eax,8),%eax
80101c81:	85 c0                	test   %eax,%eax
80101c83:	74 27                	je     80101cac <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101c85:	89 55 10             	mov    %edx,0x10(%ebp)
}
80101c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c8b:	5b                   	pop    %ebx
80101c8c:	5e                   	pop    %esi
80101c8d:	5f                   	pop    %edi
80101c8e:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101c8f:	ff e0                	jmp    *%eax
80101c91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101c98:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101c9b:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101c9e:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101ca1:	50                   	push   %eax
80101ca2:	e8 29 fa ff ff       	call   801016d0 <iupdate>
80101ca7:	83 c4 10             	add    $0x10,%esp
80101caa:	eb b5                	jmp    80101c61 <writei+0xd1>
      return -1;
80101cac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101cb1:	eb b1                	jmp    80101c64 <writei+0xd4>
80101cb3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101cc0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101cc0:	55                   	push   %ebp
80101cc1:	89 e5                	mov    %esp,%ebp
80101cc3:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101cc6:	6a 0e                	push   $0xe
80101cc8:	ff 75 0c             	push   0xc(%ebp)
80101ccb:	ff 75 08             	push   0x8(%ebp)
80101cce:	e8 5d 32 00 00       	call   80104f30 <strncmp>
}
80101cd3:	c9                   	leave  
80101cd4:	c3                   	ret    
80101cd5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101ce0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101ce0:	55                   	push   %ebp
80101ce1:	89 e5                	mov    %esp,%ebp
80101ce3:	57                   	push   %edi
80101ce4:	56                   	push   %esi
80101ce5:	53                   	push   %ebx
80101ce6:	83 ec 1c             	sub    $0x1c,%esp
80101ce9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101cec:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101cf1:	0f 85 85 00 00 00    	jne    80101d7c <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101cf7:	8b 53 58             	mov    0x58(%ebx),%edx
80101cfa:	31 ff                	xor    %edi,%edi
80101cfc:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101cff:	85 d2                	test   %edx,%edx
80101d01:	74 3e                	je     80101d41 <dirlookup+0x61>
80101d03:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101d07:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101d08:	6a 10                	push   $0x10
80101d0a:	57                   	push   %edi
80101d0b:	56                   	push   %esi
80101d0c:	53                   	push   %ebx
80101d0d:	e8 7e fd ff ff       	call   80101a90 <readi>
80101d12:	83 c4 10             	add    $0x10,%esp
80101d15:	83 f8 10             	cmp    $0x10,%eax
80101d18:	75 55                	jne    80101d6f <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101d1a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101d1f:	74 18                	je     80101d39 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101d21:	83 ec 04             	sub    $0x4,%esp
80101d24:	8d 45 da             	lea    -0x26(%ebp),%eax
80101d27:	6a 0e                	push   $0xe
80101d29:	50                   	push   %eax
80101d2a:	ff 75 0c             	push   0xc(%ebp)
80101d2d:	e8 fe 31 00 00       	call   80104f30 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101d32:	83 c4 10             	add    $0x10,%esp
80101d35:	85 c0                	test   %eax,%eax
80101d37:	74 17                	je     80101d50 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101d39:	83 c7 10             	add    $0x10,%edi
80101d3c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101d3f:	72 c7                	jb     80101d08 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101d44:	31 c0                	xor    %eax,%eax
}
80101d46:	5b                   	pop    %ebx
80101d47:	5e                   	pop    %esi
80101d48:	5f                   	pop    %edi
80101d49:	5d                   	pop    %ebp
80101d4a:	c3                   	ret    
80101d4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101d4f:	90                   	nop
      if(poff)
80101d50:	8b 45 10             	mov    0x10(%ebp),%eax
80101d53:	85 c0                	test   %eax,%eax
80101d55:	74 05                	je     80101d5c <dirlookup+0x7c>
        *poff = off;
80101d57:	8b 45 10             	mov    0x10(%ebp),%eax
80101d5a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101d5c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101d60:	8b 03                	mov    (%ebx),%eax
80101d62:	e8 e9 f5 ff ff       	call   80101350 <iget>
}
80101d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d6a:	5b                   	pop    %ebx
80101d6b:	5e                   	pop    %esi
80101d6c:	5f                   	pop    %edi
80101d6d:	5d                   	pop    %ebp
80101d6e:	c3                   	ret    
      panic("dirlookup read");
80101d6f:	83 ec 0c             	sub    $0xc,%esp
80101d72:	68 19 80 10 80       	push   $0x80108019
80101d77:	e8 04 e6 ff ff       	call   80100380 <panic>
    panic("dirlookup not DIR");
80101d7c:	83 ec 0c             	sub    $0xc,%esp
80101d7f:	68 07 80 10 80       	push   $0x80108007
80101d84:	e8 f7 e5 ff ff       	call   80100380 <panic>
80101d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101d90 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101d90:	55                   	push   %ebp
80101d91:	89 e5                	mov    %esp,%ebp
80101d93:	57                   	push   %edi
80101d94:	56                   	push   %esi
80101d95:	53                   	push   %ebx
80101d96:	89 c3                	mov    %eax,%ebx
80101d98:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101d9b:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101d9e:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101da1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101da4:	0f 84 64 01 00 00    	je     80101f0e <namex+0x17e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101daa:	e8 21 1c 00 00       	call   801039d0 <myproc>
  acquire(&icache.lock);
80101daf:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80101db2:	8b 70 68             	mov    0x68(%eax),%esi
  acquire(&icache.lock);
80101db5:	68 60 09 11 80       	push   $0x80110960
80101dba:	e8 a1 2f 00 00       	call   80104d60 <acquire>
  ip->ref++;
80101dbf:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101dc3:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101dca:	e8 31 2f 00 00       	call   80104d00 <release>
80101dcf:	83 c4 10             	add    $0x10,%esp
80101dd2:	eb 07                	jmp    80101ddb <namex+0x4b>
80101dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101dd8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101ddb:	0f b6 03             	movzbl (%ebx),%eax
80101dde:	3c 2f                	cmp    $0x2f,%al
80101de0:	74 f6                	je     80101dd8 <namex+0x48>
  if(*path == 0)
80101de2:	84 c0                	test   %al,%al
80101de4:	0f 84 06 01 00 00    	je     80101ef0 <namex+0x160>
  while(*path != '/' && *path != 0)
80101dea:	0f b6 03             	movzbl (%ebx),%eax
80101ded:	84 c0                	test   %al,%al
80101def:	0f 84 10 01 00 00    	je     80101f05 <namex+0x175>
80101df5:	89 df                	mov    %ebx,%edi
80101df7:	3c 2f                	cmp    $0x2f,%al
80101df9:	0f 84 06 01 00 00    	je     80101f05 <namex+0x175>
80101dff:	90                   	nop
80101e00:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80101e04:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80101e07:	3c 2f                	cmp    $0x2f,%al
80101e09:	74 04                	je     80101e0f <namex+0x7f>
80101e0b:	84 c0                	test   %al,%al
80101e0d:	75 f1                	jne    80101e00 <namex+0x70>
  len = path - s;
80101e0f:	89 f8                	mov    %edi,%eax
80101e11:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80101e13:	83 f8 0d             	cmp    $0xd,%eax
80101e16:	0f 8e ac 00 00 00    	jle    80101ec8 <namex+0x138>
    memmove(name, s, DIRSIZ);
80101e1c:	83 ec 04             	sub    $0x4,%esp
80101e1f:	6a 0e                	push   $0xe
80101e21:	53                   	push   %ebx
    path++;
80101e22:	89 fb                	mov    %edi,%ebx
    memmove(name, s, DIRSIZ);
80101e24:	ff 75 e4             	push   -0x1c(%ebp)
80101e27:	e8 94 30 00 00       	call   80104ec0 <memmove>
80101e2c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101e2f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101e32:	75 0c                	jne    80101e40 <namex+0xb0>
80101e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101e38:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101e3b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101e3e:	74 f8                	je     80101e38 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101e40:	83 ec 0c             	sub    $0xc,%esp
80101e43:	56                   	push   %esi
80101e44:	e8 37 f9 ff ff       	call   80101780 <ilock>
    if(ip->type != T_DIR){
80101e49:	83 c4 10             	add    $0x10,%esp
80101e4c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101e51:	0f 85 cd 00 00 00    	jne    80101f24 <namex+0x194>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101e57:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101e5a:	85 c0                	test   %eax,%eax
80101e5c:	74 09                	je     80101e67 <namex+0xd7>
80101e5e:	80 3b 00             	cmpb   $0x0,(%ebx)
80101e61:	0f 84 22 01 00 00    	je     80101f89 <namex+0x1f9>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101e67:	83 ec 04             	sub    $0x4,%esp
80101e6a:	6a 00                	push   $0x0
80101e6c:	ff 75 e4             	push   -0x1c(%ebp)
80101e6f:	56                   	push   %esi
80101e70:	e8 6b fe ff ff       	call   80101ce0 <dirlookup>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101e75:	8d 56 0c             	lea    0xc(%esi),%edx
    if((next = dirlookup(ip, name, 0)) == 0){
80101e78:	83 c4 10             	add    $0x10,%esp
80101e7b:	89 c7                	mov    %eax,%edi
80101e7d:	85 c0                	test   %eax,%eax
80101e7f:	0f 84 e1 00 00 00    	je     80101f66 <namex+0x1d6>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101e85:	83 ec 0c             	sub    $0xc,%esp
80101e88:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101e8b:	52                   	push   %edx
80101e8c:	e8 af 2c 00 00       	call   80104b40 <holdingsleep>
80101e91:	83 c4 10             	add    $0x10,%esp
80101e94:	85 c0                	test   %eax,%eax
80101e96:	0f 84 30 01 00 00    	je     80101fcc <namex+0x23c>
80101e9c:	8b 56 08             	mov    0x8(%esi),%edx
80101e9f:	85 d2                	test   %edx,%edx
80101ea1:	0f 8e 25 01 00 00    	jle    80101fcc <namex+0x23c>
  releasesleep(&ip->lock);
80101ea7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101eaa:	83 ec 0c             	sub    $0xc,%esp
80101ead:	52                   	push   %edx
80101eae:	e8 4d 2c 00 00       	call   80104b00 <releasesleep>
  iput(ip);
80101eb3:	89 34 24             	mov    %esi,(%esp)
80101eb6:	89 fe                	mov    %edi,%esi
80101eb8:	e8 f3 f9 ff ff       	call   801018b0 <iput>
80101ebd:	83 c4 10             	add    $0x10,%esp
80101ec0:	e9 16 ff ff ff       	jmp    80101ddb <namex+0x4b>
80101ec5:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80101ec8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101ecb:	8d 14 01             	lea    (%ecx,%eax,1),%edx
    memmove(name, s, len);
80101ece:	83 ec 04             	sub    $0x4,%esp
80101ed1:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ed4:	50                   	push   %eax
80101ed5:	53                   	push   %ebx
    name[len] = 0;
80101ed6:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80101ed8:	ff 75 e4             	push   -0x1c(%ebp)
80101edb:	e8 e0 2f 00 00       	call   80104ec0 <memmove>
    name[len] = 0;
80101ee0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101ee3:	83 c4 10             	add    $0x10,%esp
80101ee6:	c6 02 00             	movb   $0x0,(%edx)
80101ee9:	e9 41 ff ff ff       	jmp    80101e2f <namex+0x9f>
80101eee:	66 90                	xchg   %ax,%ax
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101ef0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101ef3:	85 c0                	test   %eax,%eax
80101ef5:	0f 85 be 00 00 00    	jne    80101fb9 <namex+0x229>
    iput(ip);
    return 0;
  }
  return ip;
}
80101efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101efe:	89 f0                	mov    %esi,%eax
80101f00:	5b                   	pop    %ebx
80101f01:	5e                   	pop    %esi
80101f02:	5f                   	pop    %edi
80101f03:	5d                   	pop    %ebp
80101f04:	c3                   	ret    
  while(*path != '/' && *path != 0)
80101f05:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101f08:	89 df                	mov    %ebx,%edi
80101f0a:	31 c0                	xor    %eax,%eax
80101f0c:	eb c0                	jmp    80101ece <namex+0x13e>
    ip = iget(ROOTDEV, ROOTINO);
80101f0e:	ba 01 00 00 00       	mov    $0x1,%edx
80101f13:	b8 01 00 00 00       	mov    $0x1,%eax
80101f18:	e8 33 f4 ff ff       	call   80101350 <iget>
80101f1d:	89 c6                	mov    %eax,%esi
80101f1f:	e9 b7 fe ff ff       	jmp    80101ddb <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f24:	83 ec 0c             	sub    $0xc,%esp
80101f27:	8d 5e 0c             	lea    0xc(%esi),%ebx
80101f2a:	53                   	push   %ebx
80101f2b:	e8 10 2c 00 00       	call   80104b40 <holdingsleep>
80101f30:	83 c4 10             	add    $0x10,%esp
80101f33:	85 c0                	test   %eax,%eax
80101f35:	0f 84 91 00 00 00    	je     80101fcc <namex+0x23c>
80101f3b:	8b 46 08             	mov    0x8(%esi),%eax
80101f3e:	85 c0                	test   %eax,%eax
80101f40:	0f 8e 86 00 00 00    	jle    80101fcc <namex+0x23c>
  releasesleep(&ip->lock);
80101f46:	83 ec 0c             	sub    $0xc,%esp
80101f49:	53                   	push   %ebx
80101f4a:	e8 b1 2b 00 00       	call   80104b00 <releasesleep>
  iput(ip);
80101f4f:	89 34 24             	mov    %esi,(%esp)
      return 0;
80101f52:	31 f6                	xor    %esi,%esi
  iput(ip);
80101f54:	e8 57 f9 ff ff       	call   801018b0 <iput>
      return 0;
80101f59:	83 c4 10             	add    $0x10,%esp
}
80101f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f5f:	89 f0                	mov    %esi,%eax
80101f61:	5b                   	pop    %ebx
80101f62:	5e                   	pop    %esi
80101f63:	5f                   	pop    %edi
80101f64:	5d                   	pop    %ebp
80101f65:	c3                   	ret    
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f66:	83 ec 0c             	sub    $0xc,%esp
80101f69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101f6c:	52                   	push   %edx
80101f6d:	e8 ce 2b 00 00       	call   80104b40 <holdingsleep>
80101f72:	83 c4 10             	add    $0x10,%esp
80101f75:	85 c0                	test   %eax,%eax
80101f77:	74 53                	je     80101fcc <namex+0x23c>
80101f79:	8b 4e 08             	mov    0x8(%esi),%ecx
80101f7c:	85 c9                	test   %ecx,%ecx
80101f7e:	7e 4c                	jle    80101fcc <namex+0x23c>
  releasesleep(&ip->lock);
80101f80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101f83:	83 ec 0c             	sub    $0xc,%esp
80101f86:	52                   	push   %edx
80101f87:	eb c1                	jmp    80101f4a <namex+0x1ba>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f89:	83 ec 0c             	sub    $0xc,%esp
80101f8c:	8d 5e 0c             	lea    0xc(%esi),%ebx
80101f8f:	53                   	push   %ebx
80101f90:	e8 ab 2b 00 00       	call   80104b40 <holdingsleep>
80101f95:	83 c4 10             	add    $0x10,%esp
80101f98:	85 c0                	test   %eax,%eax
80101f9a:	74 30                	je     80101fcc <namex+0x23c>
80101f9c:	8b 7e 08             	mov    0x8(%esi),%edi
80101f9f:	85 ff                	test   %edi,%edi
80101fa1:	7e 29                	jle    80101fcc <namex+0x23c>
  releasesleep(&ip->lock);
80101fa3:	83 ec 0c             	sub    $0xc,%esp
80101fa6:	53                   	push   %ebx
80101fa7:	e8 54 2b 00 00       	call   80104b00 <releasesleep>
}
80101fac:	83 c4 10             	add    $0x10,%esp
}
80101faf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fb2:	89 f0                	mov    %esi,%eax
80101fb4:	5b                   	pop    %ebx
80101fb5:	5e                   	pop    %esi
80101fb6:	5f                   	pop    %edi
80101fb7:	5d                   	pop    %ebp
80101fb8:	c3                   	ret    
    iput(ip);
80101fb9:	83 ec 0c             	sub    $0xc,%esp
80101fbc:	56                   	push   %esi
    return 0;
80101fbd:	31 f6                	xor    %esi,%esi
    iput(ip);
80101fbf:	e8 ec f8 ff ff       	call   801018b0 <iput>
    return 0;
80101fc4:	83 c4 10             	add    $0x10,%esp
80101fc7:	e9 2f ff ff ff       	jmp    80101efb <namex+0x16b>
    panic("iunlock");
80101fcc:	83 ec 0c             	sub    $0xc,%esp
80101fcf:	68 ff 7f 10 80       	push   $0x80107fff
80101fd4:	e8 a7 e3 ff ff       	call   80100380 <panic>
80101fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101fe0 <dirlink>:
{
80101fe0:	55                   	push   %ebp
80101fe1:	89 e5                	mov    %esp,%ebp
80101fe3:	57                   	push   %edi
80101fe4:	56                   	push   %esi
80101fe5:	53                   	push   %ebx
80101fe6:	83 ec 20             	sub    $0x20,%esp
80101fe9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80101fec:	6a 00                	push   $0x0
80101fee:	ff 75 0c             	push   0xc(%ebp)
80101ff1:	53                   	push   %ebx
80101ff2:	e8 e9 fc ff ff       	call   80101ce0 <dirlookup>
80101ff7:	83 c4 10             	add    $0x10,%esp
80101ffa:	85 c0                	test   %eax,%eax
80101ffc:	75 67                	jne    80102065 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101ffe:	8b 7b 58             	mov    0x58(%ebx),%edi
80102001:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102004:	85 ff                	test   %edi,%edi
80102006:	74 29                	je     80102031 <dirlink+0x51>
80102008:	31 ff                	xor    %edi,%edi
8010200a:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010200d:	eb 09                	jmp    80102018 <dirlink+0x38>
8010200f:	90                   	nop
80102010:	83 c7 10             	add    $0x10,%edi
80102013:	3b 7b 58             	cmp    0x58(%ebx),%edi
80102016:	73 19                	jae    80102031 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102018:	6a 10                	push   $0x10
8010201a:	57                   	push   %edi
8010201b:	56                   	push   %esi
8010201c:	53                   	push   %ebx
8010201d:	e8 6e fa ff ff       	call   80101a90 <readi>
80102022:	83 c4 10             	add    $0x10,%esp
80102025:	83 f8 10             	cmp    $0x10,%eax
80102028:	75 4e                	jne    80102078 <dirlink+0x98>
    if(de.inum == 0)
8010202a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010202f:	75 df                	jne    80102010 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102031:	83 ec 04             	sub    $0x4,%esp
80102034:	8d 45 da             	lea    -0x26(%ebp),%eax
80102037:	6a 0e                	push   $0xe
80102039:	ff 75 0c             	push   0xc(%ebp)
8010203c:	50                   	push   %eax
8010203d:	e8 3e 2f 00 00       	call   80104f80 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102042:	6a 10                	push   $0x10
  de.inum = inum;
80102044:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102047:	57                   	push   %edi
80102048:	56                   	push   %esi
80102049:	53                   	push   %ebx
  de.inum = inum;
8010204a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010204e:	e8 3d fb ff ff       	call   80101b90 <writei>
80102053:	83 c4 20             	add    $0x20,%esp
80102056:	83 f8 10             	cmp    $0x10,%eax
80102059:	75 2a                	jne    80102085 <dirlink+0xa5>
  return 0;
8010205b:	31 c0                	xor    %eax,%eax
}
8010205d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102060:	5b                   	pop    %ebx
80102061:	5e                   	pop    %esi
80102062:	5f                   	pop    %edi
80102063:	5d                   	pop    %ebp
80102064:	c3                   	ret    
    iput(ip);
80102065:	83 ec 0c             	sub    $0xc,%esp
80102068:	50                   	push   %eax
80102069:	e8 42 f8 ff ff       	call   801018b0 <iput>
    return -1;
8010206e:	83 c4 10             	add    $0x10,%esp
80102071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102076:	eb e5                	jmp    8010205d <dirlink+0x7d>
      panic("dirlink read");
80102078:	83 ec 0c             	sub    $0xc,%esp
8010207b:	68 28 80 10 80       	push   $0x80108028
80102080:	e8 fb e2 ff ff       	call   80100380 <panic>
    panic("dirlink");
80102085:	83 ec 0c             	sub    $0xc,%esp
80102088:	68 16 87 10 80       	push   $0x80108716
8010208d:	e8 ee e2 ff ff       	call   80100380 <panic>
80102092:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801020a0 <namei>:

struct inode*
namei(char *path)
{
801020a0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
801020a1:	31 d2                	xor    %edx,%edx
{
801020a3:	89 e5                	mov    %esp,%ebp
801020a5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
801020a8:	8b 45 08             	mov    0x8(%ebp),%eax
801020ab:	8d 4d ea             	lea    -0x16(%ebp),%ecx
801020ae:	e8 dd fc ff ff       	call   80101d90 <namex>
}
801020b3:	c9                   	leave  
801020b4:	c3                   	ret    
801020b5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801020c0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801020c0:	55                   	push   %ebp
  return namex(path, 1, name);
801020c1:	ba 01 00 00 00       	mov    $0x1,%edx
{
801020c6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
801020c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801020cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801020ce:	5d                   	pop    %ebp
  return namex(path, 1, name);
801020cf:	e9 bc fc ff ff       	jmp    80101d90 <namex>
801020d4:	66 90                	xchg   %ax,%ax
801020d6:	66 90                	xchg   %ax,%ax
801020d8:	66 90                	xchg   %ax,%ax
801020da:	66 90                	xchg   %ax,%ax
801020dc:	66 90                	xchg   %ax,%ax
801020de:	66 90                	xchg   %ax,%ax

801020e0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801020e0:	55                   	push   %ebp
801020e1:	89 e5                	mov    %esp,%ebp
801020e3:	57                   	push   %edi
801020e4:	56                   	push   %esi
801020e5:	53                   	push   %ebx
801020e6:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
801020e9:	85 c0                	test   %eax,%eax
801020eb:	0f 84 b4 00 00 00    	je     801021a5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
801020f1:	8b 70 08             	mov    0x8(%eax),%esi
801020f4:	89 c3                	mov    %eax,%ebx
801020f6:	81 fe e7 03 00 00    	cmp    $0x3e7,%esi
801020fc:	0f 87 96 00 00 00    	ja     80102198 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102102:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102107:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010210e:	66 90                	xchg   %ax,%ax
80102110:	89 ca                	mov    %ecx,%edx
80102112:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102113:	83 e0 c0             	and    $0xffffffc0,%eax
80102116:	3c 40                	cmp    $0x40,%al
80102118:	75 f6                	jne    80102110 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010211a:	31 ff                	xor    %edi,%edi
8010211c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102121:	89 f8                	mov    %edi,%eax
80102123:	ee                   	out    %al,(%dx)
80102124:	b8 01 00 00 00       	mov    $0x1,%eax
80102129:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010212e:	ee                   	out    %al,(%dx)
8010212f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102134:	89 f0                	mov    %esi,%eax
80102136:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102137:	89 f0                	mov    %esi,%eax
80102139:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010213e:	c1 f8 08             	sar    $0x8,%eax
80102141:	ee                   	out    %al,(%dx)
80102142:	ba f5 01 00 00       	mov    $0x1f5,%edx
80102147:	89 f8                	mov    %edi,%eax
80102149:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010214a:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
8010214e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102153:	c1 e0 04             	shl    $0x4,%eax
80102156:	83 e0 10             	and    $0x10,%eax
80102159:	83 c8 e0             	or     $0xffffffe0,%eax
8010215c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
8010215d:	f6 03 04             	testb  $0x4,(%ebx)
80102160:	75 16                	jne    80102178 <idestart+0x98>
80102162:	b8 20 00 00 00       	mov    $0x20,%eax
80102167:	89 ca                	mov    %ecx,%edx
80102169:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010216a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010216d:	5b                   	pop    %ebx
8010216e:	5e                   	pop    %esi
8010216f:	5f                   	pop    %edi
80102170:	5d                   	pop    %ebp
80102171:	c3                   	ret    
80102172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102178:	b8 30 00 00 00       	mov    $0x30,%eax
8010217d:	89 ca                	mov    %ecx,%edx
8010217f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
80102180:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
80102185:	8d 73 5c             	lea    0x5c(%ebx),%esi
80102188:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010218d:	fc                   	cld    
8010218e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
80102190:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102193:	5b                   	pop    %ebx
80102194:	5e                   	pop    %esi
80102195:	5f                   	pop    %edi
80102196:	5d                   	pop    %ebp
80102197:	c3                   	ret    
    panic("incorrect blockno");
80102198:	83 ec 0c             	sub    $0xc,%esp
8010219b:	68 94 80 10 80       	push   $0x80108094
801021a0:	e8 db e1 ff ff       	call   80100380 <panic>
    panic("idestart");
801021a5:	83 ec 0c             	sub    $0xc,%esp
801021a8:	68 8b 80 10 80       	push   $0x8010808b
801021ad:	e8 ce e1 ff ff       	call   80100380 <panic>
801021b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801021c0 <ideinit>:
{
801021c0:	55                   	push   %ebp
801021c1:	89 e5                	mov    %esp,%ebp
801021c3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
801021c6:	68 a6 80 10 80       	push   $0x801080a6
801021cb:	68 00 26 11 80       	push   $0x80112600
801021d0:	e8 bb 29 00 00       	call   80104b90 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801021d5:	58                   	pop    %eax
801021d6:	a1 84 27 11 80       	mov    0x80112784,%eax
801021db:	5a                   	pop    %edx
801021dc:	83 e8 01             	sub    $0x1,%eax
801021df:	50                   	push   %eax
801021e0:	6a 0e                	push   $0xe
801021e2:	e8 99 02 00 00       	call   80102480 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801021e7:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021ea:	ba f7 01 00 00       	mov    $0x1f7,%edx
801021ef:	90                   	nop
801021f0:	ec                   	in     (%dx),%al
801021f1:	83 e0 c0             	and    $0xffffffc0,%eax
801021f4:	3c 40                	cmp    $0x40,%al
801021f6:	75 f8                	jne    801021f0 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801021f8:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
801021fd:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102202:	ee                   	out    %al,(%dx)
80102203:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102208:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010220d:	eb 06                	jmp    80102215 <ideinit+0x55>
8010220f:	90                   	nop
  for(i=0; i<1000; i++){
80102210:	83 e9 01             	sub    $0x1,%ecx
80102213:	74 0f                	je     80102224 <ideinit+0x64>
80102215:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102216:	84 c0                	test   %al,%al
80102218:	74 f6                	je     80102210 <ideinit+0x50>
      havedisk1 = 1;
8010221a:	c7 05 e0 25 11 80 01 	movl   $0x1,0x801125e0
80102221:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102224:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102229:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010222e:	ee                   	out    %al,(%dx)
}
8010222f:	c9                   	leave  
80102230:	c3                   	ret    
80102231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102238:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010223f:	90                   	nop

80102240 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102240:	55                   	push   %ebp
80102241:	89 e5                	mov    %esp,%ebp
80102243:	57                   	push   %edi
80102244:	56                   	push   %esi
80102245:	53                   	push   %ebx
80102246:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102249:	68 00 26 11 80       	push   $0x80112600
8010224e:	e8 0d 2b 00 00       	call   80104d60 <acquire>

  if((b = idequeue) == 0){
80102253:	8b 1d e4 25 11 80    	mov    0x801125e4,%ebx
80102259:	83 c4 10             	add    $0x10,%esp
8010225c:	85 db                	test   %ebx,%ebx
8010225e:	74 63                	je     801022c3 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102260:	8b 43 58             	mov    0x58(%ebx),%eax
80102263:	a3 e4 25 11 80       	mov    %eax,0x801125e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102268:	8b 33                	mov    (%ebx),%esi
8010226a:	f7 c6 04 00 00 00    	test   $0x4,%esi
80102270:	75 2f                	jne    801022a1 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102272:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102277:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010227e:	66 90                	xchg   %ax,%ax
80102280:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102281:	89 c1                	mov    %eax,%ecx
80102283:	83 e1 c0             	and    $0xffffffc0,%ecx
80102286:	80 f9 40             	cmp    $0x40,%cl
80102289:	75 f5                	jne    80102280 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010228b:	a8 21                	test   $0x21,%al
8010228d:	75 12                	jne    801022a1 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
8010228f:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80102292:	b9 80 00 00 00       	mov    $0x80,%ecx
80102297:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010229c:	fc                   	cld    
8010229d:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010229f:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
801022a1:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
801022a4:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801022a7:	83 ce 02             	or     $0x2,%esi
801022aa:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
801022ac:	53                   	push   %ebx
801022ad:	e8 be 21 00 00       	call   80104470 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801022b2:	a1 e4 25 11 80       	mov    0x801125e4,%eax
801022b7:	83 c4 10             	add    $0x10,%esp
801022ba:	85 c0                	test   %eax,%eax
801022bc:	74 05                	je     801022c3 <ideintr+0x83>
    idestart(idequeue);
801022be:	e8 1d fe ff ff       	call   801020e0 <idestart>
    release(&idelock);
801022c3:	83 ec 0c             	sub    $0xc,%esp
801022c6:	68 00 26 11 80       	push   $0x80112600
801022cb:	e8 30 2a 00 00       	call   80104d00 <release>

  release(&idelock);
}
801022d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022d3:	5b                   	pop    %ebx
801022d4:	5e                   	pop    %esi
801022d5:	5f                   	pop    %edi
801022d6:	5d                   	pop    %ebp
801022d7:	c3                   	ret    
801022d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022df:	90                   	nop

801022e0 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801022e0:	55                   	push   %ebp
801022e1:	89 e5                	mov    %esp,%ebp
801022e3:	53                   	push   %ebx
801022e4:	83 ec 10             	sub    $0x10,%esp
801022e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801022ea:	8d 43 0c             	lea    0xc(%ebx),%eax
801022ed:	50                   	push   %eax
801022ee:	e8 4d 28 00 00       	call   80104b40 <holdingsleep>
801022f3:	83 c4 10             	add    $0x10,%esp
801022f6:	85 c0                	test   %eax,%eax
801022f8:	0f 84 c3 00 00 00    	je     801023c1 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801022fe:	8b 03                	mov    (%ebx),%eax
80102300:	83 e0 06             	and    $0x6,%eax
80102303:	83 f8 02             	cmp    $0x2,%eax
80102306:	0f 84 a8 00 00 00    	je     801023b4 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010230c:	8b 53 04             	mov    0x4(%ebx),%edx
8010230f:	85 d2                	test   %edx,%edx
80102311:	74 0d                	je     80102320 <iderw+0x40>
80102313:	a1 e0 25 11 80       	mov    0x801125e0,%eax
80102318:	85 c0                	test   %eax,%eax
8010231a:	0f 84 87 00 00 00    	je     801023a7 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102320:	83 ec 0c             	sub    $0xc,%esp
80102323:	68 00 26 11 80       	push   $0x80112600
80102328:	e8 33 2a 00 00       	call   80104d60 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010232d:	a1 e4 25 11 80       	mov    0x801125e4,%eax
  b->qnext = 0;
80102332:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102339:	83 c4 10             	add    $0x10,%esp
8010233c:	85 c0                	test   %eax,%eax
8010233e:	74 60                	je     801023a0 <iderw+0xc0>
80102340:	89 c2                	mov    %eax,%edx
80102342:	8b 40 58             	mov    0x58(%eax),%eax
80102345:	85 c0                	test   %eax,%eax
80102347:	75 f7                	jne    80102340 <iderw+0x60>
80102349:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
8010234c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010234e:	39 1d e4 25 11 80    	cmp    %ebx,0x801125e4
80102354:	74 3a                	je     80102390 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102356:	8b 03                	mov    (%ebx),%eax
80102358:	83 e0 06             	and    $0x6,%eax
8010235b:	83 f8 02             	cmp    $0x2,%eax
8010235e:	74 1b                	je     8010237b <iderw+0x9b>
    sleep(b, &idelock);
80102360:	83 ec 08             	sub    $0x8,%esp
80102363:	68 00 26 11 80       	push   $0x80112600
80102368:	53                   	push   %ebx
80102369:	e8 42 20 00 00       	call   801043b0 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010236e:	8b 03                	mov    (%ebx),%eax
80102370:	83 c4 10             	add    $0x10,%esp
80102373:	83 e0 06             	and    $0x6,%eax
80102376:	83 f8 02             	cmp    $0x2,%eax
80102379:	75 e5                	jne    80102360 <iderw+0x80>
  }


  release(&idelock);
8010237b:	c7 45 08 00 26 11 80 	movl   $0x80112600,0x8(%ebp)
}
80102382:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102385:	c9                   	leave  
  release(&idelock);
80102386:	e9 75 29 00 00       	jmp    80104d00 <release>
8010238b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010238f:	90                   	nop
    idestart(b);
80102390:	89 d8                	mov    %ebx,%eax
80102392:	e8 49 fd ff ff       	call   801020e0 <idestart>
80102397:	eb bd                	jmp    80102356 <iderw+0x76>
80102399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801023a0:	ba e4 25 11 80       	mov    $0x801125e4,%edx
801023a5:	eb a5                	jmp    8010234c <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
801023a7:	83 ec 0c             	sub    $0xc,%esp
801023aa:	68 d5 80 10 80       	push   $0x801080d5
801023af:	e8 cc df ff ff       	call   80100380 <panic>
    panic("iderw: nothing to do");
801023b4:	83 ec 0c             	sub    $0xc,%esp
801023b7:	68 c0 80 10 80       	push   $0x801080c0
801023bc:	e8 bf df ff ff       	call   80100380 <panic>
    panic("iderw: buf not locked");
801023c1:	83 ec 0c             	sub    $0xc,%esp
801023c4:	68 aa 80 10 80       	push   $0x801080aa
801023c9:	e8 b2 df ff ff       	call   80100380 <panic>
801023ce:	66 90                	xchg   %ax,%ax

801023d0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
801023d0:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801023d1:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
801023d8:	00 c0 fe 
{
801023db:	89 e5                	mov    %esp,%ebp
801023dd:	56                   	push   %esi
801023de:	53                   	push   %ebx
  ioapic->reg = reg;
801023df:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
801023e6:	00 00 00 
  return ioapic->data;
801023e9:	8b 15 34 26 11 80    	mov    0x80112634,%edx
801023ef:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
801023f2:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
801023f8:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
801023fe:	0f b6 15 80 27 11 80 	movzbl 0x80112780,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102405:	c1 ee 10             	shr    $0x10,%esi
80102408:	89 f0                	mov    %esi,%eax
8010240a:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
8010240d:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
80102410:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102413:	39 c2                	cmp    %eax,%edx
80102415:	74 16                	je     8010242d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102417:	83 ec 0c             	sub    $0xc,%esp
8010241a:	68 f4 80 10 80       	push   $0x801080f4
8010241f:	e8 7c e2 ff ff       	call   801006a0 <cprintf>
  ioapic->reg = reg;
80102424:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
8010242a:	83 c4 10             	add    $0x10,%esp
8010242d:	83 c6 21             	add    $0x21,%esi
{
80102430:	ba 10 00 00 00       	mov    $0x10,%edx
80102435:	b8 20 00 00 00       	mov    $0x20,%eax
8010243a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ioapic->reg = reg;
80102440:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102442:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
80102444:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  for(i = 0; i <= maxintr; i++){
8010244a:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010244d:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
80102453:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
80102456:	8d 5a 01             	lea    0x1(%edx),%ebx
  for(i = 0; i <= maxintr; i++){
80102459:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
8010245c:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
8010245e:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80102464:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010246b:	39 f0                	cmp    %esi,%eax
8010246d:	75 d1                	jne    80102440 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010246f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102472:	5b                   	pop    %ebx
80102473:	5e                   	pop    %esi
80102474:	5d                   	pop    %ebp
80102475:	c3                   	ret    
80102476:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010247d:	8d 76 00             	lea    0x0(%esi),%esi

80102480 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102480:	55                   	push   %ebp
  ioapic->reg = reg;
80102481:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
{
80102487:	89 e5                	mov    %esp,%ebp
80102489:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010248c:	8d 50 20             	lea    0x20(%eax),%edx
8010248f:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
80102493:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102495:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010249b:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
8010249e:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801024a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801024a4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801024a6:	a1 34 26 11 80       	mov    0x80112634,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801024ab:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801024ae:	89 50 10             	mov    %edx,0x10(%eax)
}
801024b1:	5d                   	pop    %ebp
801024b2:	c3                   	ret    
801024b3:	66 90                	xchg   %ax,%ax
801024b5:	66 90                	xchg   %ax,%ax
801024b7:	66 90                	xchg   %ax,%ax
801024b9:	66 90                	xchg   %ax,%ax
801024bb:	66 90                	xchg   %ax,%ax
801024bd:	66 90                	xchg   %ax,%ax
801024bf:	90                   	nop

801024c0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801024c0:	55                   	push   %ebp
801024c1:	89 e5                	mov    %esp,%ebp
801024c3:	53                   	push   %ebx
801024c4:	83 ec 04             	sub    $0x4,%esp
801024c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801024ca:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801024d0:	75 76                	jne    80102548 <kfree+0x88>
801024d2:	81 fb 30 6c 11 80    	cmp    $0x80116c30,%ebx
801024d8:	72 6e                	jb     80102548 <kfree+0x88>
801024da:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801024e0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801024e5:	77 61                	ja     80102548 <kfree+0x88>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801024e7:	83 ec 04             	sub    $0x4,%esp
801024ea:	68 00 10 00 00       	push   $0x1000
801024ef:	6a 01                	push   $0x1
801024f1:	53                   	push   %ebx
801024f2:	e8 29 29 00 00       	call   80104e20 <memset>

  if(kmem.use_lock)
801024f7:	8b 15 74 26 11 80    	mov    0x80112674,%edx
801024fd:	83 c4 10             	add    $0x10,%esp
80102500:	85 d2                	test   %edx,%edx
80102502:	75 1c                	jne    80102520 <kfree+0x60>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102504:	a1 78 26 11 80       	mov    0x80112678,%eax
80102509:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010250b:	a1 74 26 11 80       	mov    0x80112674,%eax
  kmem.freelist = r;
80102510:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  if(kmem.use_lock)
80102516:	85 c0                	test   %eax,%eax
80102518:	75 1e                	jne    80102538 <kfree+0x78>
    release(&kmem.lock);
}
8010251a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010251d:	c9                   	leave  
8010251e:	c3                   	ret    
8010251f:	90                   	nop
    acquire(&kmem.lock);
80102520:	83 ec 0c             	sub    $0xc,%esp
80102523:	68 40 26 11 80       	push   $0x80112640
80102528:	e8 33 28 00 00       	call   80104d60 <acquire>
8010252d:	83 c4 10             	add    $0x10,%esp
80102530:	eb d2                	jmp    80102504 <kfree+0x44>
80102532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
80102538:	c7 45 08 40 26 11 80 	movl   $0x80112640,0x8(%ebp)
}
8010253f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102542:	c9                   	leave  
    release(&kmem.lock);
80102543:	e9 b8 27 00 00       	jmp    80104d00 <release>
    panic("kfree");
80102548:	83 ec 0c             	sub    $0xc,%esp
8010254b:	68 26 81 10 80       	push   $0x80108126
80102550:	e8 2b de ff ff       	call   80100380 <panic>
80102555:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010255c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102560 <freerange>:
{
80102560:	55                   	push   %ebp
80102561:	89 e5                	mov    %esp,%ebp
80102563:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102564:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102567:	8b 75 0c             	mov    0xc(%ebp),%esi
8010256a:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010256b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102571:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102577:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010257d:	39 de                	cmp    %ebx,%esi
8010257f:	72 23                	jb     801025a4 <freerange+0x44>
80102581:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102588:	83 ec 0c             	sub    $0xc,%esp
8010258b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102591:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102597:	50                   	push   %eax
80102598:	e8 23 ff ff ff       	call   801024c0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010259d:	83 c4 10             	add    $0x10,%esp
801025a0:	39 f3                	cmp    %esi,%ebx
801025a2:	76 e4                	jbe    80102588 <freerange+0x28>
}
801025a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801025a7:	5b                   	pop    %ebx
801025a8:	5e                   	pop    %esi
801025a9:	5d                   	pop    %ebp
801025aa:	c3                   	ret    
801025ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801025af:	90                   	nop

801025b0 <kinit2>:
{
801025b0:	55                   	push   %ebp
801025b1:	89 e5                	mov    %esp,%ebp
801025b3:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801025b4:	8b 45 08             	mov    0x8(%ebp),%eax
{
801025b7:	8b 75 0c             	mov    0xc(%ebp),%esi
801025ba:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801025bb:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801025c1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801025cd:	39 de                	cmp    %ebx,%esi
801025cf:	72 23                	jb     801025f4 <kinit2+0x44>
801025d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801025d8:	83 ec 0c             	sub    $0xc,%esp
801025db:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025e1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801025e7:	50                   	push   %eax
801025e8:	e8 d3 fe ff ff       	call   801024c0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025ed:	83 c4 10             	add    $0x10,%esp
801025f0:	39 de                	cmp    %ebx,%esi
801025f2:	73 e4                	jae    801025d8 <kinit2+0x28>
  kmem.use_lock = 1;
801025f4:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
801025fb:	00 00 00 
}
801025fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102601:	5b                   	pop    %ebx
80102602:	5e                   	pop    %esi
80102603:	5d                   	pop    %ebp
80102604:	c3                   	ret    
80102605:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010260c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102610 <kinit1>:
{
80102610:	55                   	push   %ebp
80102611:	89 e5                	mov    %esp,%ebp
80102613:	56                   	push   %esi
80102614:	53                   	push   %ebx
80102615:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102618:	83 ec 08             	sub    $0x8,%esp
8010261b:	68 2c 81 10 80       	push   $0x8010812c
80102620:	68 40 26 11 80       	push   $0x80112640
80102625:	e8 66 25 00 00       	call   80104b90 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010262a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010262d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102630:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
80102637:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010263a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102640:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102646:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010264c:	39 de                	cmp    %ebx,%esi
8010264e:	72 1c                	jb     8010266c <kinit1+0x5c>
    kfree(p);
80102650:	83 ec 0c             	sub    $0xc,%esp
80102653:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102659:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010265f:	50                   	push   %eax
80102660:	e8 5b fe ff ff       	call   801024c0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102665:	83 c4 10             	add    $0x10,%esp
80102668:	39 de                	cmp    %ebx,%esi
8010266a:	73 e4                	jae    80102650 <kinit1+0x40>
}
8010266c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010266f:	5b                   	pop    %ebx
80102670:	5e                   	pop    %esi
80102671:	5d                   	pop    %ebp
80102672:	c3                   	ret    
80102673:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010267a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102680 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
80102680:	a1 74 26 11 80       	mov    0x80112674,%eax
80102685:	85 c0                	test   %eax,%eax
80102687:	75 1f                	jne    801026a8 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102689:	a1 78 26 11 80       	mov    0x80112678,%eax
  if(r)
8010268e:	85 c0                	test   %eax,%eax
80102690:	74 0e                	je     801026a0 <kalloc+0x20>
    kmem.freelist = r->next;
80102692:	8b 10                	mov    (%eax),%edx
80102694:	89 15 78 26 11 80    	mov    %edx,0x80112678
  if(kmem.use_lock)
8010269a:	c3                   	ret    
8010269b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010269f:	90                   	nop
    release(&kmem.lock);
  return (char*)r;
}
801026a0:	c3                   	ret    
801026a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
801026a8:	55                   	push   %ebp
801026a9:	89 e5                	mov    %esp,%ebp
801026ab:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
801026ae:	68 40 26 11 80       	push   $0x80112640
801026b3:	e8 a8 26 00 00       	call   80104d60 <acquire>
  r = kmem.freelist;
801026b8:	a1 78 26 11 80       	mov    0x80112678,%eax
  if(kmem.use_lock)
801026bd:	8b 15 74 26 11 80    	mov    0x80112674,%edx
  if(r)
801026c3:	83 c4 10             	add    $0x10,%esp
801026c6:	85 c0                	test   %eax,%eax
801026c8:	74 08                	je     801026d2 <kalloc+0x52>
    kmem.freelist = r->next;
801026ca:	8b 08                	mov    (%eax),%ecx
801026cc:	89 0d 78 26 11 80    	mov    %ecx,0x80112678
  if(kmem.use_lock)
801026d2:	85 d2                	test   %edx,%edx
801026d4:	74 16                	je     801026ec <kalloc+0x6c>
    release(&kmem.lock);
801026d6:	83 ec 0c             	sub    $0xc,%esp
801026d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026dc:	68 40 26 11 80       	push   $0x80112640
801026e1:	e8 1a 26 00 00       	call   80104d00 <release>
  return (char*)r;
801026e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
801026e9:	83 c4 10             	add    $0x10,%esp
}
801026ec:	c9                   	leave  
801026ed:	c3                   	ret    
801026ee:	66 90                	xchg   %ax,%ax

801026f0 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026f0:	ba 64 00 00 00       	mov    $0x64,%edx
801026f5:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801026f6:	a8 01                	test   $0x1,%al
801026f8:	0f 84 c2 00 00 00    	je     801027c0 <kbdgetc+0xd0>
{
801026fe:	55                   	push   %ebp
801026ff:	ba 60 00 00 00       	mov    $0x60,%edx
80102704:	89 e5                	mov    %esp,%ebp
80102706:	53                   	push   %ebx
80102707:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
80102708:	8b 1d 7c 26 11 80    	mov    0x8011267c,%ebx
  data = inb(KBDATAP);
8010270e:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
80102711:	3c e0                	cmp    $0xe0,%al
80102713:	74 5b                	je     80102770 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102715:	89 da                	mov    %ebx,%edx
80102717:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
8010271a:	84 c0                	test   %al,%al
8010271c:	78 62                	js     80102780 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010271e:	85 d2                	test   %edx,%edx
80102720:	74 09                	je     8010272b <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102722:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
80102725:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
80102728:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
8010272b:	0f b6 91 60 82 10 80 	movzbl -0x7fef7da0(%ecx),%edx
  shift ^= togglecode[data];
80102732:	0f b6 81 60 81 10 80 	movzbl -0x7fef7ea0(%ecx),%eax
  shift |= shiftcode[data];
80102739:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
8010273b:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010273d:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
8010273f:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
  c = charcode[shift & (CTL | SHIFT)][data];
80102745:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102748:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010274b:	8b 04 85 40 81 10 80 	mov    -0x7fef7ec0(,%eax,4),%eax
80102752:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102756:	74 0b                	je     80102763 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
80102758:	8d 50 9f             	lea    -0x61(%eax),%edx
8010275b:	83 fa 19             	cmp    $0x19,%edx
8010275e:	77 48                	ja     801027a8 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102760:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102766:	c9                   	leave  
80102767:	c3                   	ret    
80102768:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010276f:	90                   	nop
    shift |= E0ESC;
80102770:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102773:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102775:	89 1d 7c 26 11 80    	mov    %ebx,0x8011267c
}
8010277b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010277e:	c9                   	leave  
8010277f:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102780:	83 e0 7f             	and    $0x7f,%eax
80102783:	85 d2                	test   %edx,%edx
80102785:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
80102788:	0f b6 81 60 82 10 80 	movzbl -0x7fef7da0(%ecx),%eax
8010278f:	83 c8 40             	or     $0x40,%eax
80102792:	0f b6 c0             	movzbl %al,%eax
80102795:	f7 d0                	not    %eax
80102797:	21 d8                	and    %ebx,%eax
}
80102799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    shift &= ~(shiftcode[data] | E0ESC);
8010279c:	a3 7c 26 11 80       	mov    %eax,0x8011267c
    return 0;
801027a1:	31 c0                	xor    %eax,%eax
}
801027a3:	c9                   	leave  
801027a4:	c3                   	ret    
801027a5:	8d 76 00             	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
801027a8:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
801027ab:	8d 50 20             	lea    0x20(%eax),%edx
}
801027ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027b1:	c9                   	leave  
      c += 'a' - 'A';
801027b2:	83 f9 1a             	cmp    $0x1a,%ecx
801027b5:	0f 42 c2             	cmovb  %edx,%eax
}
801027b8:	c3                   	ret    
801027b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801027c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801027c5:	c3                   	ret    
801027c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027cd:	8d 76 00             	lea    0x0(%esi),%esi

801027d0 <kbdintr>:

void
kbdintr(void)
{
801027d0:	55                   	push   %ebp
801027d1:	89 e5                	mov    %esp,%ebp
801027d3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801027d6:	68 f0 26 10 80       	push   $0x801026f0
801027db:	e8 a0 e0 ff ff       	call   80100880 <consoleintr>
}
801027e0:	83 c4 10             	add    $0x10,%esp
801027e3:	c9                   	leave  
801027e4:	c3                   	ret    
801027e5:	66 90                	xchg   %ax,%ax
801027e7:	66 90                	xchg   %ax,%ax
801027e9:	66 90                	xchg   %ax,%ax
801027eb:	66 90                	xchg   %ax,%ax
801027ed:	66 90                	xchg   %ax,%ax
801027ef:	90                   	nop

801027f0 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
801027f0:	a1 80 26 11 80       	mov    0x80112680,%eax
801027f5:	85 c0                	test   %eax,%eax
801027f7:	0f 84 cb 00 00 00    	je     801028c8 <lapicinit+0xd8>
  lapic[index] = value;
801027fd:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102804:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102807:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010280a:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102811:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102814:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102817:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
8010281e:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102821:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102824:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010282b:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
8010282e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102831:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
80102838:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010283b:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010283e:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102845:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102848:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010284b:	8b 50 30             	mov    0x30(%eax),%edx
8010284e:	c1 ea 10             	shr    $0x10,%edx
80102851:	81 e2 fc 00 00 00    	and    $0xfc,%edx
80102857:	75 77                	jne    801028d0 <lapicinit+0xe0>
  lapic[index] = value;
80102859:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102860:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102863:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102866:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010286d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102870:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102873:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010287a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010287d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102880:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102887:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010288a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010288d:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102894:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102897:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010289a:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801028a1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801028a4:	8b 50 20             	mov    0x20(%eax),%edx
801028a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801028ae:	66 90                	xchg   %ax,%ax
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801028b0:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
801028b6:	80 e6 10             	and    $0x10,%dh
801028b9:	75 f5                	jne    801028b0 <lapicinit+0xc0>
  lapic[index] = value;
801028bb:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801028c2:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801028c5:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801028c8:	c3                   	ret    
801028c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
801028d0:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
801028d7:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801028da:	8b 50 20             	mov    0x20(%eax),%edx
}
801028dd:	e9 77 ff ff ff       	jmp    80102859 <lapicinit+0x69>
801028e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801028e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801028f0 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
801028f0:	a1 80 26 11 80       	mov    0x80112680,%eax
801028f5:	85 c0                	test   %eax,%eax
801028f7:	74 07                	je     80102900 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
801028f9:	8b 40 20             	mov    0x20(%eax),%eax
801028fc:	c1 e8 18             	shr    $0x18,%eax
801028ff:	c3                   	ret    
    return 0;
80102900:	31 c0                	xor    %eax,%eax
}
80102902:	c3                   	ret    
80102903:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010290a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102910 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102910:	a1 80 26 11 80       	mov    0x80112680,%eax
80102915:	85 c0                	test   %eax,%eax
80102917:	74 0d                	je     80102926 <lapiceoi+0x16>
  lapic[index] = value;
80102919:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102920:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102923:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102926:	c3                   	ret    
80102927:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010292e:	66 90                	xchg   %ax,%ax

80102930 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102930:	c3                   	ret    
80102931:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102938:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010293f:	90                   	nop

80102940 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102940:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102941:	b8 0f 00 00 00       	mov    $0xf,%eax
80102946:	ba 70 00 00 00       	mov    $0x70,%edx
8010294b:	89 e5                	mov    %esp,%ebp
8010294d:	53                   	push   %ebx
8010294e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102951:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102954:	ee                   	out    %al,(%dx)
80102955:	b8 0a 00 00 00       	mov    $0xa,%eax
8010295a:	ba 71 00 00 00       	mov    $0x71,%edx
8010295f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102960:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102962:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102965:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
8010296b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
8010296d:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
80102970:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102972:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102975:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102978:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
8010297e:	a1 80 26 11 80       	mov    0x80112680,%eax
80102983:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102989:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010298c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102993:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102996:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102999:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
801029a0:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029a3:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801029a6:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029ac:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801029af:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029b5:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801029b8:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029be:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029c1:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029c7:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
801029ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029cd:	c9                   	leave  
801029ce:	c3                   	ret    
801029cf:	90                   	nop

801029d0 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801029d0:	55                   	push   %ebp
801029d1:	b8 0b 00 00 00       	mov    $0xb,%eax
801029d6:	ba 70 00 00 00       	mov    $0x70,%edx
801029db:	89 e5                	mov    %esp,%ebp
801029dd:	57                   	push   %edi
801029de:	56                   	push   %esi
801029df:	53                   	push   %ebx
801029e0:	83 ec 4c             	sub    $0x4c,%esp
801029e3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029e4:	ba 71 00 00 00       	mov    $0x71,%edx
801029e9:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
801029ea:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ed:	bb 70 00 00 00       	mov    $0x70,%ebx
801029f2:	88 45 b3             	mov    %al,-0x4d(%ebp)
801029f5:	8d 76 00             	lea    0x0(%esi),%esi
801029f8:	31 c0                	xor    %eax,%eax
801029fa:	89 da                	mov    %ebx,%edx
801029fc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029fd:	b9 71 00 00 00       	mov    $0x71,%ecx
80102a02:	89 ca                	mov    %ecx,%edx
80102a04:	ec                   	in     (%dx),%al
80102a05:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a08:	89 da                	mov    %ebx,%edx
80102a0a:	b8 02 00 00 00       	mov    $0x2,%eax
80102a0f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a10:	89 ca                	mov    %ecx,%edx
80102a12:	ec                   	in     (%dx),%al
80102a13:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a16:	89 da                	mov    %ebx,%edx
80102a18:	b8 04 00 00 00       	mov    $0x4,%eax
80102a1d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a1e:	89 ca                	mov    %ecx,%edx
80102a20:	ec                   	in     (%dx),%al
80102a21:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a24:	89 da                	mov    %ebx,%edx
80102a26:	b8 07 00 00 00       	mov    $0x7,%eax
80102a2b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a2c:	89 ca                	mov    %ecx,%edx
80102a2e:	ec                   	in     (%dx),%al
80102a2f:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a32:	89 da                	mov    %ebx,%edx
80102a34:	b8 08 00 00 00       	mov    $0x8,%eax
80102a39:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a3a:	89 ca                	mov    %ecx,%edx
80102a3c:	ec                   	in     (%dx),%al
80102a3d:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a3f:	89 da                	mov    %ebx,%edx
80102a41:	b8 09 00 00 00       	mov    $0x9,%eax
80102a46:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a47:	89 ca                	mov    %ecx,%edx
80102a49:	ec                   	in     (%dx),%al
80102a4a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a4c:	89 da                	mov    %ebx,%edx
80102a4e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102a53:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a54:	89 ca                	mov    %ecx,%edx
80102a56:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102a57:	84 c0                	test   %al,%al
80102a59:	78 9d                	js     801029f8 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102a5b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102a5f:	89 fa                	mov    %edi,%edx
80102a61:	0f b6 fa             	movzbl %dl,%edi
80102a64:	89 f2                	mov    %esi,%edx
80102a66:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102a69:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102a6d:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a70:	89 da                	mov    %ebx,%edx
80102a72:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102a75:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102a78:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102a7c:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102a7f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102a82:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102a86:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102a89:	31 c0                	xor    %eax,%eax
80102a8b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a8c:	89 ca                	mov    %ecx,%edx
80102a8e:	ec                   	in     (%dx),%al
80102a8f:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a92:	89 da                	mov    %ebx,%edx
80102a94:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102a97:	b8 02 00 00 00       	mov    $0x2,%eax
80102a9c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a9d:	89 ca                	mov    %ecx,%edx
80102a9f:	ec                   	in     (%dx),%al
80102aa0:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aa3:	89 da                	mov    %ebx,%edx
80102aa5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102aa8:	b8 04 00 00 00       	mov    $0x4,%eax
80102aad:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102aae:	89 ca                	mov    %ecx,%edx
80102ab0:	ec                   	in     (%dx),%al
80102ab1:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ab4:	89 da                	mov    %ebx,%edx
80102ab6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102ab9:	b8 07 00 00 00       	mov    $0x7,%eax
80102abe:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102abf:	89 ca                	mov    %ecx,%edx
80102ac1:	ec                   	in     (%dx),%al
80102ac2:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ac5:	89 da                	mov    %ebx,%edx
80102ac7:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102aca:	b8 08 00 00 00       	mov    $0x8,%eax
80102acf:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ad0:	89 ca                	mov    %ecx,%edx
80102ad2:	ec                   	in     (%dx),%al
80102ad3:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ad6:	89 da                	mov    %ebx,%edx
80102ad8:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102adb:	b8 09 00 00 00       	mov    $0x9,%eax
80102ae0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ae1:	89 ca                	mov    %ecx,%edx
80102ae3:	ec                   	in     (%dx),%al
80102ae4:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102ae7:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102aea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102aed:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102af0:	6a 18                	push   $0x18
80102af2:	50                   	push   %eax
80102af3:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102af6:	50                   	push   %eax
80102af7:	e8 74 23 00 00       	call   80104e70 <memcmp>
80102afc:	83 c4 10             	add    $0x10,%esp
80102aff:	85 c0                	test   %eax,%eax
80102b01:	0f 85 f1 fe ff ff    	jne    801029f8 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102b07:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102b0b:	75 78                	jne    80102b85 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102b0d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102b10:	89 c2                	mov    %eax,%edx
80102b12:	83 e0 0f             	and    $0xf,%eax
80102b15:	c1 ea 04             	shr    $0x4,%edx
80102b18:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b1b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b1e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102b21:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102b24:	89 c2                	mov    %eax,%edx
80102b26:	83 e0 0f             	and    $0xf,%eax
80102b29:	c1 ea 04             	shr    $0x4,%edx
80102b2c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b2f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b32:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102b35:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102b38:	89 c2                	mov    %eax,%edx
80102b3a:	83 e0 0f             	and    $0xf,%eax
80102b3d:	c1 ea 04             	shr    $0x4,%edx
80102b40:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b43:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b46:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102b49:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102b4c:	89 c2                	mov    %eax,%edx
80102b4e:	83 e0 0f             	and    $0xf,%eax
80102b51:	c1 ea 04             	shr    $0x4,%edx
80102b54:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b57:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b5a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102b5d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102b60:	89 c2                	mov    %eax,%edx
80102b62:	83 e0 0f             	and    $0xf,%eax
80102b65:	c1 ea 04             	shr    $0x4,%edx
80102b68:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b6b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b6e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102b71:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102b74:	89 c2                	mov    %eax,%edx
80102b76:	83 e0 0f             	and    $0xf,%eax
80102b79:	c1 ea 04             	shr    $0x4,%edx
80102b7c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b7f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b82:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102b85:	8b 75 08             	mov    0x8(%ebp),%esi
80102b88:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102b8b:	89 06                	mov    %eax,(%esi)
80102b8d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102b90:	89 46 04             	mov    %eax,0x4(%esi)
80102b93:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102b96:	89 46 08             	mov    %eax,0x8(%esi)
80102b99:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102b9c:	89 46 0c             	mov    %eax,0xc(%esi)
80102b9f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102ba2:	89 46 10             	mov    %eax,0x10(%esi)
80102ba5:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102ba8:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102bab:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102bb5:	5b                   	pop    %ebx
80102bb6:	5e                   	pop    %esi
80102bb7:	5f                   	pop    %edi
80102bb8:	5d                   	pop    %ebp
80102bb9:	c3                   	ret    
80102bba:	66 90                	xchg   %ax,%ax
80102bbc:	66 90                	xchg   %ax,%ax
80102bbe:	66 90                	xchg   %ax,%ax

80102bc0 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102bc0:	8b 0d e8 26 11 80    	mov    0x801126e8,%ecx
80102bc6:	85 c9                	test   %ecx,%ecx
80102bc8:	0f 8e 8a 00 00 00    	jle    80102c58 <install_trans+0x98>
{
80102bce:	55                   	push   %ebp
80102bcf:	89 e5                	mov    %esp,%ebp
80102bd1:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102bd2:	31 ff                	xor    %edi,%edi
{
80102bd4:	56                   	push   %esi
80102bd5:	53                   	push   %ebx
80102bd6:	83 ec 0c             	sub    $0xc,%esp
80102bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102be0:	a1 d4 26 11 80       	mov    0x801126d4,%eax
80102be5:	83 ec 08             	sub    $0x8,%esp
80102be8:	01 f8                	add    %edi,%eax
80102bea:	83 c0 01             	add    $0x1,%eax
80102bed:	50                   	push   %eax
80102bee:	ff 35 e4 26 11 80    	push   0x801126e4
80102bf4:	e8 d7 d4 ff ff       	call   801000d0 <bread>
80102bf9:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102bfb:	58                   	pop    %eax
80102bfc:	5a                   	pop    %edx
80102bfd:	ff 34 bd ec 26 11 80 	push   -0x7feed914(,%edi,4)
80102c04:	ff 35 e4 26 11 80    	push   0x801126e4
  for (tail = 0; tail < log.lh.n; tail++) {
80102c0a:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102c0d:	e8 be d4 ff ff       	call   801000d0 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102c12:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102c15:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102c17:	8d 46 5c             	lea    0x5c(%esi),%eax
80102c1a:	68 00 02 00 00       	push   $0x200
80102c1f:	50                   	push   %eax
80102c20:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102c23:	50                   	push   %eax
80102c24:	e8 97 22 00 00       	call   80104ec0 <memmove>
    bwrite(dbuf);  // write dst to disk
80102c29:	89 1c 24             	mov    %ebx,(%esp)
80102c2c:	e8 7f d5 ff ff       	call   801001b0 <bwrite>
    brelse(lbuf);
80102c31:	89 34 24             	mov    %esi,(%esp)
80102c34:	e8 b7 d5 ff ff       	call   801001f0 <brelse>
    brelse(dbuf);
80102c39:	89 1c 24             	mov    %ebx,(%esp)
80102c3c:	e8 af d5 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102c41:	83 c4 10             	add    $0x10,%esp
80102c44:	39 3d e8 26 11 80    	cmp    %edi,0x801126e8
80102c4a:	7f 94                	jg     80102be0 <install_trans+0x20>
  }
}
80102c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c4f:	5b                   	pop    %ebx
80102c50:	5e                   	pop    %esi
80102c51:	5f                   	pop    %edi
80102c52:	5d                   	pop    %ebp
80102c53:	c3                   	ret    
80102c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102c58:	c3                   	ret    
80102c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102c60 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102c60:	55                   	push   %ebp
80102c61:	89 e5                	mov    %esp,%ebp
80102c63:	53                   	push   %ebx
80102c64:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102c67:	ff 35 d4 26 11 80    	push   0x801126d4
80102c6d:	ff 35 e4 26 11 80    	push   0x801126e4
80102c73:	e8 58 d4 ff ff       	call   801000d0 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102c78:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102c7b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102c7d:	a1 e8 26 11 80       	mov    0x801126e8,%eax
80102c82:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102c85:	85 c0                	test   %eax,%eax
80102c87:	7e 19                	jle    80102ca2 <write_head+0x42>
80102c89:	31 d2                	xor    %edx,%edx
80102c8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102c8f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102c90:	8b 0c 95 ec 26 11 80 	mov    -0x7feed914(,%edx,4),%ecx
80102c97:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102c9b:	83 c2 01             	add    $0x1,%edx
80102c9e:	39 d0                	cmp    %edx,%eax
80102ca0:	75 ee                	jne    80102c90 <write_head+0x30>
  }
  bwrite(buf);
80102ca2:	83 ec 0c             	sub    $0xc,%esp
80102ca5:	53                   	push   %ebx
80102ca6:	e8 05 d5 ff ff       	call   801001b0 <bwrite>
  brelse(buf);
80102cab:	89 1c 24             	mov    %ebx,(%esp)
80102cae:	e8 3d d5 ff ff       	call   801001f0 <brelse>
}
80102cb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102cb6:	83 c4 10             	add    $0x10,%esp
80102cb9:	c9                   	leave  
80102cba:	c3                   	ret    
80102cbb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102cbf:	90                   	nop

80102cc0 <initlog>:
{
80102cc0:	55                   	push   %ebp
80102cc1:	89 e5                	mov    %esp,%ebp
80102cc3:	53                   	push   %ebx
80102cc4:	83 ec 2c             	sub    $0x2c,%esp
80102cc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102cca:	68 60 83 10 80       	push   $0x80108360
80102ccf:	68 a0 26 11 80       	push   $0x801126a0
80102cd4:	e8 b7 1e 00 00       	call   80104b90 <initlock>
  readsb(dev, &sb);
80102cd9:	58                   	pop    %eax
80102cda:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102cdd:	5a                   	pop    %edx
80102cde:	50                   	push   %eax
80102cdf:	53                   	push   %ebx
80102ce0:	e8 3b e8 ff ff       	call   80101520 <readsb>
  log.start = sb.logstart;
80102ce5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102ce8:	59                   	pop    %ecx
  log.dev = dev;
80102ce9:	89 1d e4 26 11 80    	mov    %ebx,0x801126e4
  log.size = sb.nlog;
80102cef:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102cf2:	a3 d4 26 11 80       	mov    %eax,0x801126d4
  log.size = sb.nlog;
80102cf7:	89 15 d8 26 11 80    	mov    %edx,0x801126d8
  struct buf *buf = bread(log.dev, log.start);
80102cfd:	5a                   	pop    %edx
80102cfe:	50                   	push   %eax
80102cff:	53                   	push   %ebx
80102d00:	e8 cb d3 ff ff       	call   801000d0 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102d05:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102d08:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102d0b:	89 1d e8 26 11 80    	mov    %ebx,0x801126e8
  for (i = 0; i < log.lh.n; i++) {
80102d11:	85 db                	test   %ebx,%ebx
80102d13:	7e 1d                	jle    80102d32 <initlog+0x72>
80102d15:	31 d2                	xor    %edx,%edx
80102d17:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102d1e:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102d20:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102d24:	89 0c 95 ec 26 11 80 	mov    %ecx,-0x7feed914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102d2b:	83 c2 01             	add    $0x1,%edx
80102d2e:	39 d3                	cmp    %edx,%ebx
80102d30:	75 ee                	jne    80102d20 <initlog+0x60>
  brelse(buf);
80102d32:	83 ec 0c             	sub    $0xc,%esp
80102d35:	50                   	push   %eax
80102d36:	e8 b5 d4 ff ff       	call   801001f0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102d3b:	e8 80 fe ff ff       	call   80102bc0 <install_trans>
  log.lh.n = 0;
80102d40:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
80102d47:	00 00 00 
  write_head(); // clear the log
80102d4a:	e8 11 ff ff ff       	call   80102c60 <write_head>
}
80102d4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102d52:	83 c4 10             	add    $0x10,%esp
80102d55:	c9                   	leave  
80102d56:	c3                   	ret    
80102d57:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102d5e:	66 90                	xchg   %ax,%ax

80102d60 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102d60:	55                   	push   %ebp
80102d61:	89 e5                	mov    %esp,%ebp
80102d63:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102d66:	68 a0 26 11 80       	push   $0x801126a0
80102d6b:	e8 f0 1f 00 00       	call   80104d60 <acquire>
80102d70:	83 c4 10             	add    $0x10,%esp
80102d73:	eb 18                	jmp    80102d8d <begin_op+0x2d>
80102d75:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102d78:	83 ec 08             	sub    $0x8,%esp
80102d7b:	68 a0 26 11 80       	push   $0x801126a0
80102d80:	68 a0 26 11 80       	push   $0x801126a0
80102d85:	e8 26 16 00 00       	call   801043b0 <sleep>
80102d8a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102d8d:	a1 e0 26 11 80       	mov    0x801126e0,%eax
80102d92:	85 c0                	test   %eax,%eax
80102d94:	75 e2                	jne    80102d78 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102d96:	a1 dc 26 11 80       	mov    0x801126dc,%eax
80102d9b:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
80102da1:	83 c0 01             	add    $0x1,%eax
80102da4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102da7:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102daa:	83 fa 1e             	cmp    $0x1e,%edx
80102dad:	7f c9                	jg     80102d78 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102daf:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102db2:	a3 dc 26 11 80       	mov    %eax,0x801126dc
      release(&log.lock);
80102db7:	68 a0 26 11 80       	push   $0x801126a0
80102dbc:	e8 3f 1f 00 00       	call   80104d00 <release>
      break;
    }
  }
}
80102dc1:	83 c4 10             	add    $0x10,%esp
80102dc4:	c9                   	leave  
80102dc5:	c3                   	ret    
80102dc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102dcd:	8d 76 00             	lea    0x0(%esi),%esi

80102dd0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102dd0:	55                   	push   %ebp
80102dd1:	89 e5                	mov    %esp,%ebp
80102dd3:	57                   	push   %edi
80102dd4:	56                   	push   %esi
80102dd5:	53                   	push   %ebx
80102dd6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102dd9:	68 a0 26 11 80       	push   $0x801126a0
80102dde:	e8 7d 1f 00 00       	call   80104d60 <acquire>
  log.outstanding -= 1;
80102de3:	a1 dc 26 11 80       	mov    0x801126dc,%eax
  if(log.committing)
80102de8:	8b 35 e0 26 11 80    	mov    0x801126e0,%esi
80102dee:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102df1:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102df4:	89 1d dc 26 11 80    	mov    %ebx,0x801126dc
  if(log.committing)
80102dfa:	85 f6                	test   %esi,%esi
80102dfc:	0f 85 22 01 00 00    	jne    80102f24 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102e02:	85 db                	test   %ebx,%ebx
80102e04:	0f 85 f6 00 00 00    	jne    80102f00 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102e0a:	c7 05 e0 26 11 80 01 	movl   $0x1,0x801126e0
80102e11:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102e14:	83 ec 0c             	sub    $0xc,%esp
80102e17:	68 a0 26 11 80       	push   $0x801126a0
80102e1c:	e8 df 1e 00 00       	call   80104d00 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102e21:	8b 0d e8 26 11 80    	mov    0x801126e8,%ecx
80102e27:	83 c4 10             	add    $0x10,%esp
80102e2a:	85 c9                	test   %ecx,%ecx
80102e2c:	7f 42                	jg     80102e70 <end_op+0xa0>
    acquire(&log.lock);
80102e2e:	83 ec 0c             	sub    $0xc,%esp
80102e31:	68 a0 26 11 80       	push   $0x801126a0
80102e36:	e8 25 1f 00 00       	call   80104d60 <acquire>
    wakeup(&log);
80102e3b:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
    log.committing = 0;
80102e42:	c7 05 e0 26 11 80 00 	movl   $0x0,0x801126e0
80102e49:	00 00 00 
    wakeup(&log);
80102e4c:	e8 1f 16 00 00       	call   80104470 <wakeup>
    release(&log.lock);
80102e51:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102e58:	e8 a3 1e 00 00       	call   80104d00 <release>
80102e5d:	83 c4 10             	add    $0x10,%esp
}
80102e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e63:	5b                   	pop    %ebx
80102e64:	5e                   	pop    %esi
80102e65:	5f                   	pop    %edi
80102e66:	5d                   	pop    %ebp
80102e67:	c3                   	ret    
80102e68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102e6f:	90                   	nop
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102e70:	a1 d4 26 11 80       	mov    0x801126d4,%eax
80102e75:	83 ec 08             	sub    $0x8,%esp
80102e78:	01 d8                	add    %ebx,%eax
80102e7a:	83 c0 01             	add    $0x1,%eax
80102e7d:	50                   	push   %eax
80102e7e:	ff 35 e4 26 11 80    	push   0x801126e4
80102e84:	e8 47 d2 ff ff       	call   801000d0 <bread>
80102e89:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102e8b:	58                   	pop    %eax
80102e8c:	5a                   	pop    %edx
80102e8d:	ff 34 9d ec 26 11 80 	push   -0x7feed914(,%ebx,4)
80102e94:	ff 35 e4 26 11 80    	push   0x801126e4
  for (tail = 0; tail < log.lh.n; tail++) {
80102e9a:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102e9d:	e8 2e d2 ff ff       	call   801000d0 <bread>
    memmove(to->data, from->data, BSIZE);
80102ea2:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102ea5:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102ea7:	8d 40 5c             	lea    0x5c(%eax),%eax
80102eaa:	68 00 02 00 00       	push   $0x200
80102eaf:	50                   	push   %eax
80102eb0:	8d 46 5c             	lea    0x5c(%esi),%eax
80102eb3:	50                   	push   %eax
80102eb4:	e8 07 20 00 00       	call   80104ec0 <memmove>
    bwrite(to);  // write the log
80102eb9:	89 34 24             	mov    %esi,(%esp)
80102ebc:	e8 ef d2 ff ff       	call   801001b0 <bwrite>
    brelse(from);
80102ec1:	89 3c 24             	mov    %edi,(%esp)
80102ec4:	e8 27 d3 ff ff       	call   801001f0 <brelse>
    brelse(to);
80102ec9:	89 34 24             	mov    %esi,(%esp)
80102ecc:	e8 1f d3 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102ed1:	83 c4 10             	add    $0x10,%esp
80102ed4:	3b 1d e8 26 11 80    	cmp    0x801126e8,%ebx
80102eda:	7c 94                	jl     80102e70 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102edc:	e8 7f fd ff ff       	call   80102c60 <write_head>
    install_trans(); // Now install writes to home locations
80102ee1:	e8 da fc ff ff       	call   80102bc0 <install_trans>
    log.lh.n = 0;
80102ee6:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
80102eed:	00 00 00 
    write_head();    // Erase the transaction from the log
80102ef0:	e8 6b fd ff ff       	call   80102c60 <write_head>
80102ef5:	e9 34 ff ff ff       	jmp    80102e2e <end_op+0x5e>
80102efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
80102f00:	83 ec 0c             	sub    $0xc,%esp
80102f03:	68 a0 26 11 80       	push   $0x801126a0
80102f08:	e8 63 15 00 00       	call   80104470 <wakeup>
  release(&log.lock);
80102f0d:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102f14:	e8 e7 1d 00 00       	call   80104d00 <release>
80102f19:	83 c4 10             	add    $0x10,%esp
}
80102f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f1f:	5b                   	pop    %ebx
80102f20:	5e                   	pop    %esi
80102f21:	5f                   	pop    %edi
80102f22:	5d                   	pop    %ebp
80102f23:	c3                   	ret    
    panic("log.committing");
80102f24:	83 ec 0c             	sub    $0xc,%esp
80102f27:	68 64 83 10 80       	push   $0x80108364
80102f2c:	e8 4f d4 ff ff       	call   80100380 <panic>
80102f31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f38:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f3f:	90                   	nop

80102f40 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102f40:	55                   	push   %ebp
80102f41:	89 e5                	mov    %esp,%ebp
80102f43:	53                   	push   %ebx
80102f44:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102f47:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
{
80102f4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102f50:	83 fa 1d             	cmp    $0x1d,%edx
80102f53:	0f 8f 85 00 00 00    	jg     80102fde <log_write+0x9e>
80102f59:	a1 d8 26 11 80       	mov    0x801126d8,%eax
80102f5e:	83 e8 01             	sub    $0x1,%eax
80102f61:	39 c2                	cmp    %eax,%edx
80102f63:	7d 79                	jge    80102fde <log_write+0x9e>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102f65:	a1 dc 26 11 80       	mov    0x801126dc,%eax
80102f6a:	85 c0                	test   %eax,%eax
80102f6c:	7e 7d                	jle    80102feb <log_write+0xab>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102f6e:	83 ec 0c             	sub    $0xc,%esp
80102f71:	68 a0 26 11 80       	push   $0x801126a0
80102f76:	e8 e5 1d 00 00       	call   80104d60 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102f7b:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
80102f81:	83 c4 10             	add    $0x10,%esp
80102f84:	85 d2                	test   %edx,%edx
80102f86:	7e 4a                	jle    80102fd2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102f88:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
80102f8b:	31 c0                	xor    %eax,%eax
80102f8d:	eb 08                	jmp    80102f97 <log_write+0x57>
80102f8f:	90                   	nop
80102f90:	83 c0 01             	add    $0x1,%eax
80102f93:	39 c2                	cmp    %eax,%edx
80102f95:	74 29                	je     80102fc0 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102f97:	39 0c 85 ec 26 11 80 	cmp    %ecx,-0x7feed914(,%eax,4)
80102f9e:	75 f0                	jne    80102f90 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
80102fa0:	89 0c 85 ec 26 11 80 	mov    %ecx,-0x7feed914(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102fa7:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
80102faa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
80102fad:	c7 45 08 a0 26 11 80 	movl   $0x801126a0,0x8(%ebp)
}
80102fb4:	c9                   	leave  
  release(&log.lock);
80102fb5:	e9 46 1d 00 00       	jmp    80104d00 <release>
80102fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80102fc0:	89 0c 95 ec 26 11 80 	mov    %ecx,-0x7feed914(,%edx,4)
    log.lh.n++;
80102fc7:	83 c2 01             	add    $0x1,%edx
80102fca:	89 15 e8 26 11 80    	mov    %edx,0x801126e8
80102fd0:	eb d5                	jmp    80102fa7 <log_write+0x67>
  log.lh.block[i] = b->blockno;
80102fd2:	8b 43 08             	mov    0x8(%ebx),%eax
80102fd5:	a3 ec 26 11 80       	mov    %eax,0x801126ec
  if (i == log.lh.n)
80102fda:	75 cb                	jne    80102fa7 <log_write+0x67>
80102fdc:	eb e9                	jmp    80102fc7 <log_write+0x87>
    panic("too big a transaction");
80102fde:	83 ec 0c             	sub    $0xc,%esp
80102fe1:	68 73 83 10 80       	push   $0x80108373
80102fe6:	e8 95 d3 ff ff       	call   80100380 <panic>
    panic("log_write outside of trans");
80102feb:	83 ec 0c             	sub    $0xc,%esp
80102fee:	68 89 83 10 80       	push   $0x80108389
80102ff3:	e8 88 d3 ff ff       	call   80100380 <panic>
80102ff8:	66 90                	xchg   %ax,%ax
80102ffa:	66 90                	xchg   %ax,%ax
80102ffc:	66 90                	xchg   %ax,%ax
80102ffe:	66 90                	xchg   %ax,%ax

80103000 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
80103003:	53                   	push   %ebx
80103004:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103007:	e8 a4 09 00 00       	call   801039b0 <cpuid>
8010300c:	89 c3                	mov    %eax,%ebx
8010300e:	e8 9d 09 00 00       	call   801039b0 <cpuid>
80103013:	83 ec 04             	sub    $0x4,%esp
80103016:	53                   	push   %ebx
80103017:	50                   	push   %eax
80103018:	68 a4 83 10 80       	push   $0x801083a4
8010301d:	e8 7e d6 ff ff       	call   801006a0 <cprintf>
  idtinit();       // load idt register
80103022:	e8 b9 31 00 00       	call   801061e0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103027:	e8 24 09 00 00       	call   80103950 <mycpu>
8010302c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010302e:	b8 01 00 00 00       	mov    $0x1,%eax
80103033:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010303a:	e8 51 0c 00 00       	call   80103c90 <scheduler>
8010303f:	90                   	nop

80103040 <mpenter>:
{
80103040:	55                   	push   %ebp
80103041:	89 e5                	mov    %esp,%ebp
80103043:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103046:	e8 f5 43 00 00       	call   80107440 <switchkvm>
  seginit();
8010304b:	e8 60 43 00 00       	call   801073b0 <seginit>
  lapicinit();
80103050:	e8 9b f7 ff ff       	call   801027f0 <lapicinit>
  mpmain();
80103055:	e8 a6 ff ff ff       	call   80103000 <mpmain>
8010305a:	66 90                	xchg   %ax,%ax
8010305c:	66 90                	xchg   %ax,%ax
8010305e:	66 90                	xchg   %ax,%ax

80103060 <main>:
{
80103060:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103064:	83 e4 f0             	and    $0xfffffff0,%esp
80103067:	ff 71 fc             	push   -0x4(%ecx)
8010306a:	55                   	push   %ebp
8010306b:	89 e5                	mov    %esp,%ebp
8010306d:	53                   	push   %ebx
8010306e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010306f:	83 ec 08             	sub    $0x8,%esp
80103072:	68 00 00 40 80       	push   $0x80400000
80103077:	68 30 6c 11 80       	push   $0x80116c30
8010307c:	e8 8f f5 ff ff       	call   80102610 <kinit1>
  kvmalloc();      // kernel page table
80103081:	e8 aa 48 00 00       	call   80107930 <kvmalloc>
  mpinit();        // detect other processors
80103086:	e8 85 01 00 00       	call   80103210 <mpinit>
  lapicinit();     // interrupt controller
8010308b:	e8 60 f7 ff ff       	call   801027f0 <lapicinit>
  seginit();       // segment descriptors
80103090:	e8 1b 43 00 00       	call   801073b0 <seginit>
  picinit();       // disable pic
80103095:	e8 76 03 00 00       	call   80103410 <picinit>
  ioapicinit();    // another interrupt controller
8010309a:	e8 31 f3 ff ff       	call   801023d0 <ioapicinit>
  consoleinit();   // console hardware
8010309f:	e8 bc d9 ff ff       	call   80100a60 <consoleinit>
  uartinit();      // serial port
801030a4:	e8 97 35 00 00       	call   80106640 <uartinit>
  pinit();         // process table
801030a9:	e8 62 08 00 00       	call   80103910 <pinit>
  tvinit();        // trap vectors
801030ae:	e8 5d 30 00 00       	call   80106110 <tvinit>
  binit();         // buffer cache
801030b3:	e8 88 cf ff ff       	call   80100040 <binit>
  fileinit();      // file table
801030b8:	e8 53 dd ff ff       	call   80100e10 <fileinit>
  ideinit();       // disk 
801030bd:	e8 fe f0 ff ff       	call   801021c0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801030c2:	83 c4 0c             	add    $0xc,%esp
801030c5:	68 8a 00 00 00       	push   $0x8a
801030ca:	68 8c b4 10 80       	push   $0x8010b48c
801030cf:	68 00 70 00 80       	push   $0x80007000
801030d4:	e8 e7 1d 00 00       	call   80104ec0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801030d9:	83 c4 10             	add    $0x10,%esp
801030dc:	69 05 84 27 11 80 b4 	imul   $0xb4,0x80112784,%eax
801030e3:	00 00 00 
801030e6:	05 a0 27 11 80       	add    $0x801127a0,%eax
801030eb:	3d a0 27 11 80       	cmp    $0x801127a0,%eax
801030f0:	76 7e                	jbe    80103170 <main+0x110>
801030f2:	bb a0 27 11 80       	mov    $0x801127a0,%ebx
801030f7:	eb 20                	jmp    80103119 <main+0xb9>
801030f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103100:	69 05 84 27 11 80 b4 	imul   $0xb4,0x80112784,%eax
80103107:	00 00 00 
8010310a:	81 c3 b4 00 00 00    	add    $0xb4,%ebx
80103110:	05 a0 27 11 80       	add    $0x801127a0,%eax
80103115:	39 c3                	cmp    %eax,%ebx
80103117:	73 57                	jae    80103170 <main+0x110>
    if(c == mycpu())  // We've started already.
80103119:	e8 32 08 00 00       	call   80103950 <mycpu>
8010311e:	39 c3                	cmp    %eax,%ebx
80103120:	74 de                	je     80103100 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103122:	e8 59 f5 ff ff       	call   80102680 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80103127:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
8010312a:	c7 05 f8 6f 00 80 40 	movl   $0x80103040,0x80006ff8
80103131:	30 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103134:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
8010313b:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
8010313e:	05 00 10 00 00       	add    $0x1000,%eax
80103143:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
80103148:	0f b6 03             	movzbl (%ebx),%eax
8010314b:	68 00 70 00 00       	push   $0x7000
80103150:	50                   	push   %eax
80103151:	e8 ea f7 ff ff       	call   80102940 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103156:	83 c4 10             	add    $0x10,%esp
80103159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103160:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103166:	85 c0                	test   %eax,%eax
80103168:	74 f6                	je     80103160 <main+0x100>
8010316a:	eb 94                	jmp    80103100 <main+0xa0>
8010316c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103170:	83 ec 08             	sub    $0x8,%esp
80103173:	68 00 00 00 8e       	push   $0x8e000000
80103178:	68 00 00 40 80       	push   $0x80400000
8010317d:	e8 2e f4 ff ff       	call   801025b0 <kinit2>
  userinit();      // first user process
80103182:	e8 79 08 00 00       	call   80103a00 <userinit>
  mpmain();        // finish this processor's setup
80103187:	e8 74 fe ff ff       	call   80103000 <mpmain>
8010318c:	66 90                	xchg   %ax,%ax
8010318e:	66 90                	xchg   %ax,%ax

80103190 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103190:	55                   	push   %ebp
80103191:	89 e5                	mov    %esp,%ebp
80103193:	57                   	push   %edi
80103194:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103195:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010319b:	53                   	push   %ebx
  e = addr+len;
8010319c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010319f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
801031a2:	39 de                	cmp    %ebx,%esi
801031a4:	72 10                	jb     801031b6 <mpsearch1+0x26>
801031a6:	eb 50                	jmp    801031f8 <mpsearch1+0x68>
801031a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801031af:	90                   	nop
801031b0:	89 fe                	mov    %edi,%esi
801031b2:	39 fb                	cmp    %edi,%ebx
801031b4:	76 42                	jbe    801031f8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801031b6:	83 ec 04             	sub    $0x4,%esp
801031b9:	8d 7e 10             	lea    0x10(%esi),%edi
801031bc:	6a 04                	push   $0x4
801031be:	68 b8 83 10 80       	push   $0x801083b8
801031c3:	56                   	push   %esi
801031c4:	e8 a7 1c 00 00       	call   80104e70 <memcmp>
801031c9:	83 c4 10             	add    $0x10,%esp
801031cc:	85 c0                	test   %eax,%eax
801031ce:	75 e0                	jne    801031b0 <mpsearch1+0x20>
801031d0:	89 f2                	mov    %esi,%edx
801031d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801031d8:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801031db:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801031de:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801031e0:	39 fa                	cmp    %edi,%edx
801031e2:	75 f4                	jne    801031d8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801031e4:	84 c0                	test   %al,%al
801031e6:	75 c8                	jne    801031b0 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801031e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031eb:	89 f0                	mov    %esi,%eax
801031ed:	5b                   	pop    %ebx
801031ee:	5e                   	pop    %esi
801031ef:	5f                   	pop    %edi
801031f0:	5d                   	pop    %ebp
801031f1:	c3                   	ret    
801031f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801031f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801031fb:	31 f6                	xor    %esi,%esi
}
801031fd:	5b                   	pop    %ebx
801031fe:	89 f0                	mov    %esi,%eax
80103200:	5e                   	pop    %esi
80103201:	5f                   	pop    %edi
80103202:	5d                   	pop    %ebp
80103203:	c3                   	ret    
80103204:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010320b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010320f:	90                   	nop

80103210 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103210:	55                   	push   %ebp
80103211:	89 e5                	mov    %esp,%ebp
80103213:	57                   	push   %edi
80103214:	56                   	push   %esi
80103215:	53                   	push   %ebx
80103216:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103219:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103220:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103227:	c1 e0 08             	shl    $0x8,%eax
8010322a:	09 d0                	or     %edx,%eax
8010322c:	c1 e0 04             	shl    $0x4,%eax
8010322f:	75 1b                	jne    8010324c <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103231:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80103238:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
8010323f:	c1 e0 08             	shl    $0x8,%eax
80103242:	09 d0                	or     %edx,%eax
80103244:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103247:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010324c:	ba 00 04 00 00       	mov    $0x400,%edx
80103251:	e8 3a ff ff ff       	call   80103190 <mpsearch1>
80103256:	89 c3                	mov    %eax,%ebx
80103258:	85 c0                	test   %eax,%eax
8010325a:	0f 84 40 01 00 00    	je     801033a0 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103260:	8b 73 04             	mov    0x4(%ebx),%esi
80103263:	85 f6                	test   %esi,%esi
80103265:	0f 84 25 01 00 00    	je     80103390 <mpinit+0x180>
  if(memcmp(conf, "PCMP", 4) != 0)
8010326b:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010326e:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103274:	6a 04                	push   $0x4
80103276:	68 bd 83 10 80       	push   $0x801083bd
8010327b:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010327c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010327f:	e8 ec 1b 00 00       	call   80104e70 <memcmp>
80103284:	83 c4 10             	add    $0x10,%esp
80103287:	85 c0                	test   %eax,%eax
80103289:	0f 85 01 01 00 00    	jne    80103390 <mpinit+0x180>
  if(conf->version != 1 && conf->version != 4)
8010328f:	0f b6 86 06 00 00 80 	movzbl -0x7ffffffa(%esi),%eax
80103296:	3c 01                	cmp    $0x1,%al
80103298:	74 08                	je     801032a2 <mpinit+0x92>
8010329a:	3c 04                	cmp    $0x4,%al
8010329c:	0f 85 ee 00 00 00    	jne    80103390 <mpinit+0x180>
  if(sum((uchar*)conf, conf->length) != 0)
801032a2:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
801032a9:	66 85 d2             	test   %dx,%dx
801032ac:	74 22                	je     801032d0 <mpinit+0xc0>
801032ae:	8d 3c 32             	lea    (%edx,%esi,1),%edi
801032b1:	89 f0                	mov    %esi,%eax
  sum = 0;
801032b3:	31 d2                	xor    %edx,%edx
801032b5:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801032b8:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
  for(i=0; i<len; i++)
801032bf:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
801032c2:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
801032c4:	39 c7                	cmp    %eax,%edi
801032c6:	75 f0                	jne    801032b8 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
801032c8:	84 d2                	test   %dl,%dl
801032ca:	0f 85 c0 00 00 00    	jne    80103390 <mpinit+0x180>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
801032d0:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
801032d6:	a3 80 26 11 80       	mov    %eax,0x80112680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801032db:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
801032e2:	8d 86 2c 00 00 80    	lea    -0x7fffffd4(%esi),%eax
  ismp = 1;
801032e8:	be 01 00 00 00       	mov    $0x1,%esi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801032ed:	03 55 e4             	add    -0x1c(%ebp),%edx
801032f0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801032f3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801032f7:	90                   	nop
801032f8:	39 d0                	cmp    %edx,%eax
801032fa:	73 15                	jae    80103311 <mpinit+0x101>
    switch(*p){
801032fc:	0f b6 08             	movzbl (%eax),%ecx
801032ff:	80 f9 02             	cmp    $0x2,%cl
80103302:	74 4c                	je     80103350 <mpinit+0x140>
80103304:	77 3a                	ja     80103340 <mpinit+0x130>
80103306:	84 c9                	test   %cl,%cl
80103308:	74 56                	je     80103360 <mpinit+0x150>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010330a:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010330d:	39 d0                	cmp    %edx,%eax
8010330f:	72 eb                	jb     801032fc <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103311:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103314:	85 f6                	test   %esi,%esi
80103316:	0f 84 d9 00 00 00    	je     801033f5 <mpinit+0x1e5>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
8010331c:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
80103320:	74 15                	je     80103337 <mpinit+0x127>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103322:	b8 70 00 00 00       	mov    $0x70,%eax
80103327:	ba 22 00 00 00       	mov    $0x22,%edx
8010332c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010332d:	ba 23 00 00 00       	mov    $0x23,%edx
80103332:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103333:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103336:	ee                   	out    %al,(%dx)
  }
}
80103337:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010333a:	5b                   	pop    %ebx
8010333b:	5e                   	pop    %esi
8010333c:	5f                   	pop    %edi
8010333d:	5d                   	pop    %ebp
8010333e:	c3                   	ret    
8010333f:	90                   	nop
    switch(*p){
80103340:	83 e9 03             	sub    $0x3,%ecx
80103343:	80 f9 01             	cmp    $0x1,%cl
80103346:	76 c2                	jbe    8010330a <mpinit+0xfa>
80103348:	31 f6                	xor    %esi,%esi
8010334a:	eb ac                	jmp    801032f8 <mpinit+0xe8>
8010334c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103350:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
80103354:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103357:	88 0d 80 27 11 80    	mov    %cl,0x80112780
      continue;
8010335d:	eb 99                	jmp    801032f8 <mpinit+0xe8>
8010335f:	90                   	nop
      if(ncpu < NCPU) {
80103360:	8b 0d 84 27 11 80    	mov    0x80112784,%ecx
80103366:	83 f9 07             	cmp    $0x7,%ecx
80103369:	7f 19                	jg     80103384 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010336b:	69 f9 b4 00 00 00    	imul   $0xb4,%ecx,%edi
80103371:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103375:	83 c1 01             	add    $0x1,%ecx
80103378:	89 0d 84 27 11 80    	mov    %ecx,0x80112784
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010337e:	88 9f a0 27 11 80    	mov    %bl,-0x7feed860(%edi)
      p += sizeof(struct mpproc);
80103384:	83 c0 14             	add    $0x14,%eax
      continue;
80103387:	e9 6c ff ff ff       	jmp    801032f8 <mpinit+0xe8>
8010338c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
80103390:	83 ec 0c             	sub    $0xc,%esp
80103393:	68 c2 83 10 80       	push   $0x801083c2
80103398:	e8 e3 cf ff ff       	call   80100380 <panic>
8010339d:	8d 76 00             	lea    0x0(%esi),%esi
{
801033a0:	bb 00 00 0f 80       	mov    $0x800f0000,%ebx
801033a5:	eb 13                	jmp    801033ba <mpinit+0x1aa>
801033a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033ae:	66 90                	xchg   %ax,%ax
  for(p = addr; p < e; p += sizeof(struct mp))
801033b0:	89 f3                	mov    %esi,%ebx
801033b2:	81 fe 00 00 10 80    	cmp    $0x80100000,%esi
801033b8:	74 d6                	je     80103390 <mpinit+0x180>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801033ba:	83 ec 04             	sub    $0x4,%esp
801033bd:	8d 73 10             	lea    0x10(%ebx),%esi
801033c0:	6a 04                	push   $0x4
801033c2:	68 b8 83 10 80       	push   $0x801083b8
801033c7:	53                   	push   %ebx
801033c8:	e8 a3 1a 00 00       	call   80104e70 <memcmp>
801033cd:	83 c4 10             	add    $0x10,%esp
801033d0:	85 c0                	test   %eax,%eax
801033d2:	75 dc                	jne    801033b0 <mpinit+0x1a0>
801033d4:	89 da                	mov    %ebx,%edx
801033d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033dd:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801033e0:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801033e3:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801033e6:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801033e8:	39 d6                	cmp    %edx,%esi
801033ea:	75 f4                	jne    801033e0 <mpinit+0x1d0>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801033ec:	84 c0                	test   %al,%al
801033ee:	75 c0                	jne    801033b0 <mpinit+0x1a0>
801033f0:	e9 6b fe ff ff       	jmp    80103260 <mpinit+0x50>
    panic("Didn't find a suitable machine");
801033f5:	83 ec 0c             	sub    $0xc,%esp
801033f8:	68 dc 83 10 80       	push   $0x801083dc
801033fd:	e8 7e cf ff ff       	call   80100380 <panic>
80103402:	66 90                	xchg   %ax,%ax
80103404:	66 90                	xchg   %ax,%ax
80103406:	66 90                	xchg   %ax,%ax
80103408:	66 90                	xchg   %ax,%ax
8010340a:	66 90                	xchg   %ax,%ax
8010340c:	66 90                	xchg   %ax,%ax
8010340e:	66 90                	xchg   %ax,%ax

80103410 <picinit>:
80103410:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103415:	ba 21 00 00 00       	mov    $0x21,%edx
8010341a:	ee                   	out    %al,(%dx)
8010341b:	ba a1 00 00 00       	mov    $0xa1,%edx
80103420:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103421:	c3                   	ret    
80103422:	66 90                	xchg   %ax,%ax
80103424:	66 90                	xchg   %ax,%ax
80103426:	66 90                	xchg   %ax,%ax
80103428:	66 90                	xchg   %ax,%ax
8010342a:	66 90                	xchg   %ax,%ax
8010342c:	66 90                	xchg   %ax,%ax
8010342e:	66 90                	xchg   %ax,%ax

80103430 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103430:	55                   	push   %ebp
80103431:	89 e5                	mov    %esp,%ebp
80103433:	57                   	push   %edi
80103434:	56                   	push   %esi
80103435:	53                   	push   %ebx
80103436:	83 ec 0c             	sub    $0xc,%esp
80103439:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010343c:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
8010343f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103445:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010344b:	e8 e0 d9 ff ff       	call   80100e30 <filealloc>
80103450:	89 03                	mov    %eax,(%ebx)
80103452:	85 c0                	test   %eax,%eax
80103454:	0f 84 a8 00 00 00    	je     80103502 <pipealloc+0xd2>
8010345a:	e8 d1 d9 ff ff       	call   80100e30 <filealloc>
8010345f:	89 06                	mov    %eax,(%esi)
80103461:	85 c0                	test   %eax,%eax
80103463:	0f 84 87 00 00 00    	je     801034f0 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103469:	e8 12 f2 ff ff       	call   80102680 <kalloc>
8010346e:	89 c7                	mov    %eax,%edi
80103470:	85 c0                	test   %eax,%eax
80103472:	0f 84 b0 00 00 00    	je     80103528 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
80103478:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010347f:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103482:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
80103485:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010348c:	00 00 00 
  p->nwrite = 0;
8010348f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103496:	00 00 00 
  p->nread = 0;
80103499:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801034a0:	00 00 00 
  initlock(&p->lock, "pipe");
801034a3:	68 fb 83 10 80       	push   $0x801083fb
801034a8:	50                   	push   %eax
801034a9:	e8 e2 16 00 00       	call   80104b90 <initlock>
  (*f0)->type = FD_PIPE;
801034ae:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
801034b0:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801034b3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801034b9:	8b 03                	mov    (%ebx),%eax
801034bb:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801034bf:	8b 03                	mov    (%ebx),%eax
801034c1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801034c5:	8b 03                	mov    (%ebx),%eax
801034c7:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801034ca:	8b 06                	mov    (%esi),%eax
801034cc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801034d2:	8b 06                	mov    (%esi),%eax
801034d4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801034d8:	8b 06                	mov    (%esi),%eax
801034da:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801034de:	8b 06                	mov    (%esi),%eax
801034e0:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801034e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801034e6:	31 c0                	xor    %eax,%eax
}
801034e8:	5b                   	pop    %ebx
801034e9:	5e                   	pop    %esi
801034ea:	5f                   	pop    %edi
801034eb:	5d                   	pop    %ebp
801034ec:	c3                   	ret    
801034ed:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
801034f0:	8b 03                	mov    (%ebx),%eax
801034f2:	85 c0                	test   %eax,%eax
801034f4:	74 1e                	je     80103514 <pipealloc+0xe4>
    fileclose(*f0);
801034f6:	83 ec 0c             	sub    $0xc,%esp
801034f9:	50                   	push   %eax
801034fa:	e8 f1 d9 ff ff       	call   80100ef0 <fileclose>
801034ff:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103502:	8b 06                	mov    (%esi),%eax
80103504:	85 c0                	test   %eax,%eax
80103506:	74 0c                	je     80103514 <pipealloc+0xe4>
    fileclose(*f1);
80103508:	83 ec 0c             	sub    $0xc,%esp
8010350b:	50                   	push   %eax
8010350c:	e8 df d9 ff ff       	call   80100ef0 <fileclose>
80103511:	83 c4 10             	add    $0x10,%esp
}
80103514:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80103517:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010351c:	5b                   	pop    %ebx
8010351d:	5e                   	pop    %esi
8010351e:	5f                   	pop    %edi
8010351f:	5d                   	pop    %ebp
80103520:	c3                   	ret    
80103521:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
80103528:	8b 03                	mov    (%ebx),%eax
8010352a:	85 c0                	test   %eax,%eax
8010352c:	75 c8                	jne    801034f6 <pipealloc+0xc6>
8010352e:	eb d2                	jmp    80103502 <pipealloc+0xd2>

80103530 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103530:	55                   	push   %ebp
80103531:	89 e5                	mov    %esp,%ebp
80103533:	56                   	push   %esi
80103534:	53                   	push   %ebx
80103535:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103538:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
8010353b:	83 ec 0c             	sub    $0xc,%esp
8010353e:	53                   	push   %ebx
8010353f:	e8 1c 18 00 00       	call   80104d60 <acquire>
  if(writable){
80103544:	83 c4 10             	add    $0x10,%esp
80103547:	85 f6                	test   %esi,%esi
80103549:	74 65                	je     801035b0 <pipeclose+0x80>
    p->writeopen = 0;
    wakeup(&p->nread);
8010354b:	83 ec 0c             	sub    $0xc,%esp
8010354e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
80103554:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010355b:	00 00 00 
    wakeup(&p->nread);
8010355e:	50                   	push   %eax
8010355f:	e8 0c 0f 00 00       	call   80104470 <wakeup>
80103564:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103567:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010356d:	85 d2                	test   %edx,%edx
8010356f:	75 0a                	jne    8010357b <pipeclose+0x4b>
80103571:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103577:	85 c0                	test   %eax,%eax
80103579:	74 15                	je     80103590 <pipeclose+0x60>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010357b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010357e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103581:	5b                   	pop    %ebx
80103582:	5e                   	pop    %esi
80103583:	5d                   	pop    %ebp
    release(&p->lock);
80103584:	e9 77 17 00 00       	jmp    80104d00 <release>
80103589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    release(&p->lock);
80103590:	83 ec 0c             	sub    $0xc,%esp
80103593:	53                   	push   %ebx
80103594:	e8 67 17 00 00       	call   80104d00 <release>
    kfree((char*)p);
80103599:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010359c:	83 c4 10             	add    $0x10,%esp
}
8010359f:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035a2:	5b                   	pop    %ebx
801035a3:	5e                   	pop    %esi
801035a4:	5d                   	pop    %ebp
    kfree((char*)p);
801035a5:	e9 16 ef ff ff       	jmp    801024c0 <kfree>
801035aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
801035b0:	83 ec 0c             	sub    $0xc,%esp
801035b3:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
801035b9:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801035c0:	00 00 00 
    wakeup(&p->nwrite);
801035c3:	50                   	push   %eax
801035c4:	e8 a7 0e 00 00       	call   80104470 <wakeup>
801035c9:	83 c4 10             	add    $0x10,%esp
801035cc:	eb 99                	jmp    80103567 <pipeclose+0x37>
801035ce:	66 90                	xchg   %ax,%ax

801035d0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801035d0:	55                   	push   %ebp
801035d1:	89 e5                	mov    %esp,%ebp
801035d3:	57                   	push   %edi
801035d4:	56                   	push   %esi
801035d5:	53                   	push   %ebx
801035d6:	83 ec 28             	sub    $0x28,%esp
801035d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801035dc:	53                   	push   %ebx
801035dd:	e8 7e 17 00 00       	call   80104d60 <acquire>
  for(i = 0; i < n; i++){
801035e2:	8b 45 10             	mov    0x10(%ebp),%eax
801035e5:	83 c4 10             	add    $0x10,%esp
801035e8:	85 c0                	test   %eax,%eax
801035ea:	0f 8e c0 00 00 00    	jle    801036b0 <pipewrite+0xe0>
801035f0:	8b 45 0c             	mov    0xc(%ebp),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801035f3:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801035f9:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
801035ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103602:	03 45 10             	add    0x10(%ebp),%eax
80103605:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103608:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010360e:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103614:	89 ca                	mov    %ecx,%edx
80103616:	05 00 02 00 00       	add    $0x200,%eax
8010361b:	39 c1                	cmp    %eax,%ecx
8010361d:	74 3f                	je     8010365e <pipewrite+0x8e>
8010361f:	eb 67                	jmp    80103688 <pipewrite+0xb8>
80103621:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->readopen == 0 || myproc()->killed){
80103628:	e8 a3 03 00 00       	call   801039d0 <myproc>
8010362d:	8b 48 24             	mov    0x24(%eax),%ecx
80103630:	85 c9                	test   %ecx,%ecx
80103632:	75 34                	jne    80103668 <pipewrite+0x98>
      wakeup(&p->nread);
80103634:	83 ec 0c             	sub    $0xc,%esp
80103637:	57                   	push   %edi
80103638:	e8 33 0e 00 00       	call   80104470 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010363d:	58                   	pop    %eax
8010363e:	5a                   	pop    %edx
8010363f:	53                   	push   %ebx
80103640:	56                   	push   %esi
80103641:	e8 6a 0d 00 00       	call   801043b0 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103646:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010364c:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103652:	83 c4 10             	add    $0x10,%esp
80103655:	05 00 02 00 00       	add    $0x200,%eax
8010365a:	39 c2                	cmp    %eax,%edx
8010365c:	75 2a                	jne    80103688 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
8010365e:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103664:	85 c0                	test   %eax,%eax
80103666:	75 c0                	jne    80103628 <pipewrite+0x58>
        release(&p->lock);
80103668:	83 ec 0c             	sub    $0xc,%esp
8010366b:	53                   	push   %ebx
8010366c:	e8 8f 16 00 00       	call   80104d00 <release>
        return -1;
80103671:	83 c4 10             	add    $0x10,%esp
80103674:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103679:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010367c:	5b                   	pop    %ebx
8010367d:	5e                   	pop    %esi
8010367e:	5f                   	pop    %edi
8010367f:	5d                   	pop    %ebp
80103680:	c3                   	ret    
80103681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103688:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010368b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010368e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103694:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
8010369a:	0f b6 06             	movzbl (%esi),%eax
  for(i = 0; i < n; i++){
8010369d:	83 c6 01             	add    $0x1,%esi
801036a0:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801036a3:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801036a7:	3b 75 e0             	cmp    -0x20(%ebp),%esi
801036aa:	0f 85 58 ff ff ff    	jne    80103608 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801036b0:	83 ec 0c             	sub    $0xc,%esp
801036b3:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801036b9:	50                   	push   %eax
801036ba:	e8 b1 0d 00 00       	call   80104470 <wakeup>
  release(&p->lock);
801036bf:	89 1c 24             	mov    %ebx,(%esp)
801036c2:	e8 39 16 00 00       	call   80104d00 <release>
  return n;
801036c7:	8b 45 10             	mov    0x10(%ebp),%eax
801036ca:	83 c4 10             	add    $0x10,%esp
801036cd:	eb aa                	jmp    80103679 <pipewrite+0xa9>
801036cf:	90                   	nop

801036d0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801036d0:	55                   	push   %ebp
801036d1:	89 e5                	mov    %esp,%ebp
801036d3:	57                   	push   %edi
801036d4:	56                   	push   %esi
801036d5:	53                   	push   %ebx
801036d6:	83 ec 18             	sub    $0x18,%esp
801036d9:	8b 75 08             	mov    0x8(%ebp),%esi
801036dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801036df:	56                   	push   %esi
801036e0:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
801036e6:	e8 75 16 00 00       	call   80104d60 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801036eb:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
801036f1:	83 c4 10             	add    $0x10,%esp
801036f4:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
801036fa:	74 2f                	je     8010372b <piperead+0x5b>
801036fc:	eb 37                	jmp    80103735 <piperead+0x65>
801036fe:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
80103700:	e8 cb 02 00 00       	call   801039d0 <myproc>
80103705:	8b 48 24             	mov    0x24(%eax),%ecx
80103708:	85 c9                	test   %ecx,%ecx
8010370a:	0f 85 80 00 00 00    	jne    80103790 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103710:	83 ec 08             	sub    $0x8,%esp
80103713:	56                   	push   %esi
80103714:	53                   	push   %ebx
80103715:	e8 96 0c 00 00       	call   801043b0 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010371a:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
80103720:	83 c4 10             	add    $0x10,%esp
80103723:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
80103729:	75 0a                	jne    80103735 <piperead+0x65>
8010372b:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
80103731:	85 c0                	test   %eax,%eax
80103733:	75 cb                	jne    80103700 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103735:	8b 55 10             	mov    0x10(%ebp),%edx
80103738:	31 db                	xor    %ebx,%ebx
8010373a:	85 d2                	test   %edx,%edx
8010373c:	7f 20                	jg     8010375e <piperead+0x8e>
8010373e:	eb 2c                	jmp    8010376c <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103740:	8d 48 01             	lea    0x1(%eax),%ecx
80103743:	25 ff 01 00 00       	and    $0x1ff,%eax
80103748:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
8010374e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103753:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103756:	83 c3 01             	add    $0x1,%ebx
80103759:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010375c:	74 0e                	je     8010376c <piperead+0x9c>
    if(p->nread == p->nwrite)
8010375e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103764:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
8010376a:	75 d4                	jne    80103740 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010376c:	83 ec 0c             	sub    $0xc,%esp
8010376f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103775:	50                   	push   %eax
80103776:	e8 f5 0c 00 00       	call   80104470 <wakeup>
  release(&p->lock);
8010377b:	89 34 24             	mov    %esi,(%esp)
8010377e:	e8 7d 15 00 00       	call   80104d00 <release>
  return i;
80103783:	83 c4 10             	add    $0x10,%esp
}
80103786:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103789:	89 d8                	mov    %ebx,%eax
8010378b:	5b                   	pop    %ebx
8010378c:	5e                   	pop    %esi
8010378d:	5f                   	pop    %edi
8010378e:	5d                   	pop    %ebp
8010378f:	c3                   	ret    
      release(&p->lock);
80103790:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103793:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103798:	56                   	push   %esi
80103799:	e8 62 15 00 00       	call   80104d00 <release>
      return -1;
8010379e:	83 c4 10             	add    $0x10,%esp
}
801037a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801037a4:	89 d8                	mov    %ebx,%eax
801037a6:	5b                   	pop    %ebx
801037a7:	5e                   	pop    %esi
801037a8:	5f                   	pop    %edi
801037a9:	5d                   	pop    %ebp
801037aa:	c3                   	ret    
801037ab:	66 90                	xchg   %ax,%ax
801037ad:	66 90                	xchg   %ax,%ax
801037af:	90                   	nop

801037b0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801037b0:	55                   	push   %ebp
801037b1:	89 e5                	mov    %esp,%ebp
801037b3:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801037b4:	bb b4 30 11 80       	mov    $0x801130b4,%ebx
{
801037b9:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801037bc:	68 80 30 11 80       	push   $0x80113080
801037c1:	e8 9a 15 00 00       	call   80104d60 <acquire>
801037c6:	83 c4 10             	add    $0x10,%esp
801037c9:	eb 17                	jmp    801037e2 <allocproc+0x32>
801037cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801037cf:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801037d0:	81 c3 8c 00 00 00    	add    $0x8c,%ebx
801037d6:	81 fb b4 53 11 80    	cmp    $0x801153b4,%ebx
801037dc:	0f 84 ae 00 00 00    	je     80103890 <allocproc+0xe0>
    if(p->state == UNUSED)
801037e2:	8b 43 0c             	mov    0xc(%ebx),%eax
801037e5:	85 c0                	test   %eax,%eax
801037e7:	75 e7                	jne    801037d0 <allocproc+0x20>
  release(&ptable.lock);
  return 0; // 프로세스 생성 공간이 부족할 경우 0을 리턴하고 fork 리턴값이 -1이 됨.

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
801037e9:	a1 04 b0 10 80       	mov    0x8010b004,%eax

  p->lev = 0;
  p->tq = 0;
  p->priority = 3;
  p->locked = 0;
  enqueue(&mlfq.l0, p); // push process to (L0) queue
801037ee:	83 ec 08             	sub    $0x8,%esp
  p->state = EMBRYO;
801037f1:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->lev = 0;
801037f8:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
  p->pid = nextpid++;
801037ff:	89 43 10             	mov    %eax,0x10(%ebx)
80103802:	8d 50 01             	lea    0x1(%eax),%edx
  p->tq = 0;
80103805:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
8010380c:	00 00 00 
  p->priority = 3;
8010380f:	c7 83 84 00 00 00 03 	movl   $0x3,0x84(%ebx)
80103816:	00 00 00 
  p->locked = 0;
80103819:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
80103820:	00 00 00 
  enqueue(&mlfq.l0, p); // push process to (L0) queue
80103823:	53                   	push   %ebx
80103824:	68 40 2d 11 80       	push   $0x80112d40
  p->pid = nextpid++;
80103829:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  enqueue(&mlfq.l0, p); // push process to (L0) queue
8010382f:	e8 cc 44 00 00       	call   80107d00 <enqueue>

  release(&ptable.lock);
80103834:	c7 04 24 80 30 11 80 	movl   $0x80113080,(%esp)
8010383b:	e8 c0 14 00 00       	call   80104d00 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103840:	e8 3b ee ff ff       	call   80102680 <kalloc>
80103845:	83 c4 10             	add    $0x10,%esp
80103848:	89 43 08             	mov    %eax,0x8(%ebx)
8010384b:	85 c0                	test   %eax,%eax
8010384d:	74 5a                	je     801038a9 <allocproc+0xf9>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010384f:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
80103855:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103858:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
8010385d:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103860:	c7 40 14 ff 60 10 80 	movl   $0x801060ff,0x14(%eax)
  p->context = (struct context*)sp;
80103867:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010386a:	6a 14                	push   $0x14
8010386c:	6a 00                	push   $0x0
8010386e:	50                   	push   %eax
8010386f:	e8 ac 15 00 00       	call   80104e20 <memset>
  p->context->eip = (uint)forkret;
80103874:	8b 43 1c             	mov    0x1c(%ebx),%eax

  return p;
80103877:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010387a:	c7 40 10 c0 38 10 80 	movl   $0x801038c0,0x10(%eax)
}
80103881:	89 d8                	mov    %ebx,%eax
80103883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103886:	c9                   	leave  
80103887:	c3                   	ret    
80103888:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010388f:	90                   	nop
  release(&ptable.lock);
80103890:	83 ec 0c             	sub    $0xc,%esp
  return 0; // 프로세스 생성 공간이 부족할 경우 0을 리턴하고 fork 리턴값이 -1이 됨.
80103893:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
80103895:	68 80 30 11 80       	push   $0x80113080
8010389a:	e8 61 14 00 00       	call   80104d00 <release>
}
8010389f:	89 d8                	mov    %ebx,%eax
  return 0; // 프로세스 생성 공간이 부족할 경우 0을 리턴하고 fork 리턴값이 -1이 됨.
801038a1:	83 c4 10             	add    $0x10,%esp
}
801038a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038a7:	c9                   	leave  
801038a8:	c3                   	ret    
    p->state = UNUSED;
801038a9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801038b0:	31 db                	xor    %ebx,%ebx
}
801038b2:	89 d8                	mov    %ebx,%eax
801038b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038b7:	c9                   	leave  
801038b8:	c3                   	ret    
801038b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801038c0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801038c0:	55                   	push   %ebp
801038c1:	89 e5                	mov    %esp,%ebp
801038c3:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801038c6:	68 80 30 11 80       	push   $0x80113080
801038cb:	e8 30 14 00 00       	call   80104d00 <release>

  if (first) {
801038d0:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801038d5:	83 c4 10             	add    $0x10,%esp
801038d8:	85 c0                	test   %eax,%eax
801038da:	75 04                	jne    801038e0 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801038dc:	c9                   	leave  
801038dd:	c3                   	ret    
801038de:	66 90                	xchg   %ax,%ax
    first = 0;
801038e0:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
801038e7:	00 00 00 
    iinit(ROOTDEV);
801038ea:	83 ec 0c             	sub    $0xc,%esp
801038ed:	6a 01                	push   $0x1
801038ef:	e8 6c dc ff ff       	call   80101560 <iinit>
    initlog(ROOTDEV);
801038f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801038fb:	e8 c0 f3 ff ff       	call   80102cc0 <initlog>
}
80103900:	83 c4 10             	add    $0x10,%esp
80103903:	c9                   	leave  
80103904:	c3                   	ret    
80103905:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010390c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103910 <pinit>:
{
80103910:	55                   	push   %ebp
80103911:	89 e5                	mov    %esp,%ebp
80103913:	83 ec 14             	sub    $0x14,%esp
  initQueue(&mlfq.l0);
80103916:	68 40 2d 11 80       	push   $0x80112d40
8010391b:	e8 40 43 00 00       	call   80107c60 <initQueue>
  initQueue(&mlfq.l1);
80103920:	c7 04 24 50 2e 11 80 	movl   $0x80112e50,(%esp)
80103927:	e8 34 43 00 00       	call   80107c60 <initQueue>
  initQueue(&mlfq.l2);
8010392c:	c7 04 24 60 2f 11 80 	movl   $0x80112f60,(%esp)
80103933:	e8 28 43 00 00       	call   80107c60 <initQueue>
  initlock(&ptable.lock, "ptable");
80103938:	58                   	pop    %eax
80103939:	5a                   	pop    %edx
8010393a:	68 00 84 10 80       	push   $0x80108400
8010393f:	68 80 30 11 80       	push   $0x80113080
80103944:	e8 47 12 00 00       	call   80104b90 <initlock>
}
80103949:	83 c4 10             	add    $0x10,%esp
8010394c:	c9                   	leave  
8010394d:	c3                   	ret    
8010394e:	66 90                	xchg   %ax,%ax

80103950 <mycpu>:
{
80103950:	55                   	push   %ebp
80103951:	89 e5                	mov    %esp,%ebp
80103953:	56                   	push   %esi
80103954:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103955:	9c                   	pushf  
80103956:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103957:	f6 c4 02             	test   $0x2,%ah
8010395a:	75 46                	jne    801039a2 <mycpu+0x52>
  apicid = lapicid();
8010395c:	e8 8f ef ff ff       	call   801028f0 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103961:	8b 35 84 27 11 80    	mov    0x80112784,%esi
80103967:	85 f6                	test   %esi,%esi
80103969:	7e 2a                	jle    80103995 <mycpu+0x45>
8010396b:	31 d2                	xor    %edx,%edx
8010396d:	eb 08                	jmp    80103977 <mycpu+0x27>
8010396f:	90                   	nop
80103970:	83 c2 01             	add    $0x1,%edx
80103973:	39 f2                	cmp    %esi,%edx
80103975:	74 1e                	je     80103995 <mycpu+0x45>
    if (cpus[i].apicid == apicid)
80103977:	69 ca b4 00 00 00    	imul   $0xb4,%edx,%ecx
8010397d:	0f b6 99 a0 27 11 80 	movzbl -0x7feed860(%ecx),%ebx
80103984:	39 c3                	cmp    %eax,%ebx
80103986:	75 e8                	jne    80103970 <mycpu+0x20>
}
80103988:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
8010398b:	8d 81 a0 27 11 80    	lea    -0x7feed860(%ecx),%eax
}
80103991:	5b                   	pop    %ebx
80103992:	5e                   	pop    %esi
80103993:	5d                   	pop    %ebp
80103994:	c3                   	ret    
  panic("unknown apicid\n");
80103995:	83 ec 0c             	sub    $0xc,%esp
80103998:	68 07 84 10 80       	push   $0x80108407
8010399d:	e8 de c9 ff ff       	call   80100380 <panic>
    panic("mycpu called with interrupts enabled\n");
801039a2:	83 ec 0c             	sub    $0xc,%esp
801039a5:	68 38 85 10 80       	push   $0x80108538
801039aa:	e8 d1 c9 ff ff       	call   80100380 <panic>
801039af:	90                   	nop

801039b0 <cpuid>:
cpuid() {
801039b0:	55                   	push   %ebp
801039b1:	89 e5                	mov    %esp,%ebp
801039b3:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039b6:	e8 95 ff ff ff       	call   80103950 <mycpu>
}
801039bb:	c9                   	leave  
  return mycpu()-cpus;
801039bc:	2d a0 27 11 80       	sub    $0x801127a0,%eax
801039c1:	c1 f8 02             	sar    $0x2,%eax
801039c4:	69 c0 a5 4f fa a4    	imul   $0xa4fa4fa5,%eax,%eax
}
801039ca:	c3                   	ret    
801039cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801039cf:	90                   	nop

801039d0 <myproc>:
myproc(void) {
801039d0:	55                   	push   %ebp
801039d1:	89 e5                	mov    %esp,%ebp
801039d3:	53                   	push   %ebx
801039d4:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801039d7:	e8 34 12 00 00       	call   80104c10 <pushcli>
  c = mycpu();
801039dc:	e8 6f ff ff ff       	call   80103950 <mycpu>
  p = c->proc;
801039e1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801039e7:	e8 74 12 00 00       	call   80104c60 <popcli>
}
801039ec:	89 d8                	mov    %ebx,%eax
801039ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039f1:	c9                   	leave  
801039f2:	c3                   	ret    
801039f3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801039fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103a00 <userinit>:
{
80103a00:	55                   	push   %ebp
80103a01:	89 e5                	mov    %esp,%ebp
80103a03:	53                   	push   %ebx
80103a04:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103a07:	e8 a4 fd ff ff       	call   801037b0 <allocproc>
80103a0c:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103a0e:	a3 b4 53 11 80       	mov    %eax,0x801153b4
  if((p->pgdir = setupkvm()) == 0)
80103a13:	e8 98 3e 00 00       	call   801078b0 <setupkvm>
80103a18:	89 43 04             	mov    %eax,0x4(%ebx)
80103a1b:	85 c0                	test   %eax,%eax
80103a1d:	0f 84 bd 00 00 00    	je     80103ae0 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103a23:	83 ec 04             	sub    $0x4,%esp
80103a26:	68 2c 00 00 00       	push   $0x2c
80103a2b:	68 60 b4 10 80       	push   $0x8010b460
80103a30:	50                   	push   %eax
80103a31:	e8 2a 3b 00 00       	call   80107560 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103a36:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103a39:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103a3f:	6a 4c                	push   $0x4c
80103a41:	6a 00                	push   $0x0
80103a43:	ff 73 18             	push   0x18(%ebx)
80103a46:	e8 d5 13 00 00       	call   80104e20 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103a4b:	8b 43 18             	mov    0x18(%ebx),%eax
80103a4e:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a53:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103a56:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103a5b:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103a5f:	8b 43 18             	mov    0x18(%ebx),%eax
80103a62:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103a66:	8b 43 18             	mov    0x18(%ebx),%eax
80103a69:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a6d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103a71:	8b 43 18             	mov    0x18(%ebx),%eax
80103a74:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a78:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103a7c:	8b 43 18             	mov    0x18(%ebx),%eax
80103a7f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103a86:	8b 43 18             	mov    0x18(%ebx),%eax
80103a89:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103a90:	8b 43 18             	mov    0x18(%ebx),%eax
80103a93:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a9a:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103a9d:	6a 10                	push   $0x10
80103a9f:	68 30 84 10 80       	push   $0x80108430
80103aa4:	50                   	push   %eax
80103aa5:	e8 36 15 00 00       	call   80104fe0 <safestrcpy>
  p->cwd = namei("/");
80103aaa:	c7 04 24 39 84 10 80 	movl   $0x80108439,(%esp)
80103ab1:	e8 ea e5 ff ff       	call   801020a0 <namei>
80103ab6:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103ab9:	c7 04 24 80 30 11 80 	movl   $0x80113080,(%esp)
80103ac0:	e8 9b 12 00 00       	call   80104d60 <acquire>
  p->state = RUNNABLE;
80103ac5:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103acc:	c7 04 24 80 30 11 80 	movl   $0x80113080,(%esp)
80103ad3:	e8 28 12 00 00       	call   80104d00 <release>
}
80103ad8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103adb:	83 c4 10             	add    $0x10,%esp
80103ade:	c9                   	leave  
80103adf:	c3                   	ret    
    panic("userinit: out of memory?");
80103ae0:	83 ec 0c             	sub    $0xc,%esp
80103ae3:	68 17 84 10 80       	push   $0x80108417
80103ae8:	e8 93 c8 ff ff       	call   80100380 <panic>
80103aed:	8d 76 00             	lea    0x0(%esi),%esi

80103af0 <growproc>:
{
80103af0:	55                   	push   %ebp
80103af1:	89 e5                	mov    %esp,%ebp
80103af3:	56                   	push   %esi
80103af4:	53                   	push   %ebx
80103af5:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103af8:	e8 13 11 00 00       	call   80104c10 <pushcli>
  c = mycpu();
80103afd:	e8 4e fe ff ff       	call   80103950 <mycpu>
  p = c->proc;
80103b02:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103b08:	e8 53 11 00 00       	call   80104c60 <popcli>
  sz = curproc->sz;
80103b0d:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103b0f:	85 f6                	test   %esi,%esi
80103b11:	7f 1d                	jg     80103b30 <growproc+0x40>
  } else if(n < 0){
80103b13:	75 3b                	jne    80103b50 <growproc+0x60>
  switchuvm(curproc);
80103b15:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103b18:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103b1a:	53                   	push   %ebx
80103b1b:	e8 30 39 00 00       	call   80107450 <switchuvm>
  return 0;
80103b20:	83 c4 10             	add    $0x10,%esp
80103b23:	31 c0                	xor    %eax,%eax
}
80103b25:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b28:	5b                   	pop    %ebx
80103b29:	5e                   	pop    %esi
80103b2a:	5d                   	pop    %ebp
80103b2b:	c3                   	ret    
80103b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103b30:	83 ec 04             	sub    $0x4,%esp
80103b33:	01 c6                	add    %eax,%esi
80103b35:	56                   	push   %esi
80103b36:	50                   	push   %eax
80103b37:	ff 73 04             	push   0x4(%ebx)
80103b3a:	e8 91 3b 00 00       	call   801076d0 <allocuvm>
80103b3f:	83 c4 10             	add    $0x10,%esp
80103b42:	85 c0                	test   %eax,%eax
80103b44:	75 cf                	jne    80103b15 <growproc+0x25>
      return -1;
80103b46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103b4b:	eb d8                	jmp    80103b25 <growproc+0x35>
80103b4d:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103b50:	83 ec 04             	sub    $0x4,%esp
80103b53:	01 c6                	add    %eax,%esi
80103b55:	56                   	push   %esi
80103b56:	50                   	push   %eax
80103b57:	ff 73 04             	push   0x4(%ebx)
80103b5a:	e8 a1 3c 00 00       	call   80107800 <deallocuvm>
80103b5f:	83 c4 10             	add    $0x10,%esp
80103b62:	85 c0                	test   %eax,%eax
80103b64:	75 af                	jne    80103b15 <growproc+0x25>
80103b66:	eb de                	jmp    80103b46 <growproc+0x56>
80103b68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103b6f:	90                   	nop

80103b70 <fork>:
{
80103b70:	55                   	push   %ebp
80103b71:	89 e5                	mov    %esp,%ebp
80103b73:	57                   	push   %edi
80103b74:	56                   	push   %esi
80103b75:	53                   	push   %ebx
80103b76:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103b79:	e8 92 10 00 00       	call   80104c10 <pushcli>
  c = mycpu();
80103b7e:	e8 cd fd ff ff       	call   80103950 <mycpu>
  p = c->proc;
80103b83:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103b89:	e8 d2 10 00 00       	call   80104c60 <popcli>
  if((np = allocproc()) == 0){
80103b8e:	e8 1d fc ff ff       	call   801037b0 <allocproc>
80103b93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103b96:	85 c0                	test   %eax,%eax
80103b98:	0f 84 b7 00 00 00    	je     80103c55 <fork+0xe5>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103b9e:	83 ec 08             	sub    $0x8,%esp
80103ba1:	ff 33                	push   (%ebx)
80103ba3:	89 c7                	mov    %eax,%edi
80103ba5:	ff 73 04             	push   0x4(%ebx)
80103ba8:	e8 f3 3d 00 00       	call   801079a0 <copyuvm>
80103bad:	83 c4 10             	add    $0x10,%esp
80103bb0:	89 47 04             	mov    %eax,0x4(%edi)
80103bb3:	85 c0                	test   %eax,%eax
80103bb5:	0f 84 a1 00 00 00    	je     80103c5c <fork+0xec>
  np->sz = curproc->sz;
80103bbb:	8b 03                	mov    (%ebx),%eax
80103bbd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103bc0:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
80103bc2:	8b 79 18             	mov    0x18(%ecx),%edi
  np->parent = curproc;
80103bc5:	89 c8                	mov    %ecx,%eax
80103bc7:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103bca:	b9 13 00 00 00       	mov    $0x13,%ecx
80103bcf:	8b 73 18             	mov    0x18(%ebx),%esi
80103bd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103bd4:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103bd6:	8b 40 18             	mov    0x18(%eax),%eax
80103bd9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    if(curproc->ofile[i])
80103be0:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103be4:	85 c0                	test   %eax,%eax
80103be6:	74 13                	je     80103bfb <fork+0x8b>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103be8:	83 ec 0c             	sub    $0xc,%esp
80103beb:	50                   	push   %eax
80103bec:	e8 af d2 ff ff       	call   80100ea0 <filedup>
80103bf1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103bf4:	83 c4 10             	add    $0x10,%esp
80103bf7:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103bfb:	83 c6 01             	add    $0x1,%esi
80103bfe:	83 fe 10             	cmp    $0x10,%esi
80103c01:	75 dd                	jne    80103be0 <fork+0x70>
  np->cwd = idup(curproc->cwd);
80103c03:	83 ec 0c             	sub    $0xc,%esp
80103c06:	ff 73 68             	push   0x68(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103c09:	83 c3 6c             	add    $0x6c,%ebx
  np->cwd = idup(curproc->cwd);
80103c0c:	e8 3f db ff ff       	call   80101750 <idup>
80103c11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103c14:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103c17:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103c1a:	8d 47 6c             	lea    0x6c(%edi),%eax
80103c1d:	6a 10                	push   $0x10
80103c1f:	53                   	push   %ebx
80103c20:	50                   	push   %eax
80103c21:	e8 ba 13 00 00       	call   80104fe0 <safestrcpy>
  pid = np->pid;
80103c26:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103c29:	c7 04 24 80 30 11 80 	movl   $0x80113080,(%esp)
80103c30:	e8 2b 11 00 00       	call   80104d60 <acquire>
  np->state = RUNNABLE;
80103c35:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103c3c:	c7 04 24 80 30 11 80 	movl   $0x80113080,(%esp)
80103c43:	e8 b8 10 00 00       	call   80104d00 <release>
  return pid;
80103c48:	83 c4 10             	add    $0x10,%esp
}
80103c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103c4e:	89 d8                	mov    %ebx,%eax
80103c50:	5b                   	pop    %ebx
80103c51:	5e                   	pop    %esi
80103c52:	5f                   	pop    %edi
80103c53:	5d                   	pop    %ebp
80103c54:	c3                   	ret    
    return -1;
80103c55:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103c5a:	eb ef                	jmp    80103c4b <fork+0xdb>
    kfree(np->kstack);
80103c5c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103c5f:	83 ec 0c             	sub    $0xc,%esp
80103c62:	ff 73 08             	push   0x8(%ebx)
80103c65:	e8 56 e8 ff ff       	call   801024c0 <kfree>
    np->kstack = 0;
80103c6a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    return -1;
80103c71:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80103c74:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103c7b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103c80:	eb c9                	jmp    80103c4b <fork+0xdb>
80103c82:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103c90 <scheduler>:
{
80103c90:	55                   	push   %ebp
80103c91:	89 e5                	mov    %esp,%ebp
80103c93:	57                   	push   %edi
80103c94:	56                   	push   %esi
80103c95:	53                   	push   %ebx
80103c96:	83 ec 1c             	sub    $0x1c,%esp
  struct cpu *c = mycpu();
80103c99:	e8 b2 fc ff ff       	call   80103950 <mycpu>
  c->proc = 0;
80103c9e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103ca5:	00 00 00 
  struct cpu *c = mycpu();
80103ca8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  c->proc = 0;
80103cab:	83 c0 04             	add    $0x4,%eax
80103cae:	89 45 e0             	mov    %eax,-0x20(%ebp)
80103cb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("sti");
80103cb8:	fb                   	sti    
    acquire(&ptable.lock);
80103cb9:	83 ec 0c             	sub    $0xc,%esp
80103cbc:	68 80 30 11 80       	push   $0x80113080
80103cc1:	e8 9a 10 00 00       	call   80104d60 <acquire>
    size = mlfq.l0.count;
80103cc6:	8b 1d 48 2d 11 80    	mov    0x80112d48,%ebx
    while(size--){
80103ccc:	83 c4 10             	add    $0x10,%esp
80103ccf:	85 db                	test   %ebx,%ebx
80103cd1:	0f 84 f1 00 00 00    	je     80103dc8 <scheduler+0x138>
    runnable_flag = 0;
80103cd7:	31 f6                	xor    %esi,%esi
80103cd9:	eb 46                	jmp    80103d21 <scheduler+0x91>
80103cdb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103cdf:	90                   	nop
        dequeue(&mlfq.l0);
80103ce0:	83 ec 0c             	sub    $0xc,%esp
80103ce3:	68 40 2d 11 80       	push   $0x80112d40
80103ce8:	e8 53 40 00 00       	call   80107d40 <dequeue>
        if(p->lev == 0 && p->state != UNUSED && p->state != ZOMBIE){
80103ced:	8b 47 7c             	mov    0x7c(%edi),%eax
80103cf0:	83 c4 10             	add    $0x10,%esp
80103cf3:	85 c0                	test   %eax,%eax
80103cf5:	75 21                	jne    80103d18 <scheduler+0x88>
80103cf7:	8b 47 0c             	mov    0xc(%edi),%eax
80103cfa:	85 c0                	test   %eax,%eax
80103cfc:	74 1a                	je     80103d18 <scheduler+0x88>
80103cfe:	83 f8 05             	cmp    $0x5,%eax
80103d01:	74 15                	je     80103d18 <scheduler+0x88>
          enqueue(&mlfq.l0, p); // 맨 뒤로 보냄
80103d03:	83 ec 08             	sub    $0x8,%esp
80103d06:	57                   	push   %edi
80103d07:	68 40 2d 11 80       	push   $0x80112d40
80103d0c:	e8 ef 3f 00 00       	call   80107d00 <enqueue>
80103d11:	83 c4 10             	add    $0x10,%esp
80103d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(size--){
80103d18:	83 eb 01             	sub    $0x1,%ebx
80103d1b:	0f 84 9f 00 00 00    	je     80103dc0 <scheduler+0x130>
      p = top(&mlfq.l0);
80103d21:	83 ec 0c             	sub    $0xc,%esp
80103d24:	68 40 2d 11 80       	push   $0x80112d40
80103d29:	e8 52 40 00 00       	call   80107d80 <top>
      if(p->lev == 0 && p->state == RUNNABLE){ // RUNNABLE한 프로세스인 경우 switch
80103d2e:	83 c4 10             	add    $0x10,%esp
      p = top(&mlfq.l0);
80103d31:	89 c7                	mov    %eax,%edi
      if(p->lev == 0 && p->state == RUNNABLE){ // RUNNABLE한 프로세스인 경우 switch
80103d33:	8b 40 7c             	mov    0x7c(%eax),%eax
80103d36:	85 c0                	test   %eax,%eax
80103d38:	75 a6                	jne    80103ce0 <scheduler+0x50>
80103d3a:	83 7f 0c 03          	cmpl   $0x3,0xc(%edi)
80103d3e:	75 a0                	jne    80103ce0 <scheduler+0x50>
        c->proc = p;
80103d40:	8b 75 e4             	mov    -0x1c(%ebp),%esi
        switchuvm(p);
80103d43:	83 ec 0c             	sub    $0xc,%esp
        c->proc = p;
80103d46:	89 be ac 00 00 00    	mov    %edi,0xac(%esi)
        switchuvm(p);
80103d4c:	57                   	push   %edi
80103d4d:	e8 fe 36 00 00       	call   80107450 <switchuvm>
        p->state = RUNNING;
80103d52:	c7 47 0c 04 00 00 00 	movl   $0x4,0xc(%edi)
        swtch(&(c->scheduler), p->context);
80103d59:	58                   	pop    %eax
80103d5a:	5a                   	pop    %edx
80103d5b:	ff 77 1c             	push   0x1c(%edi)
80103d5e:	ff 75 e0             	push   -0x20(%ebp)
80103d61:	e8 d5 12 00 00       	call   8010503b <swtch>
        switchkvm();
80103d66:	e8 d5 36 00 00       	call   80107440 <switchkvm>
        if(!ticks) // priority boosting이 발생한 경우
80103d6b:	8b 0d c0 53 11 80    	mov    0x801153c0,%ecx
80103d71:	83 c4 10             	add    $0x10,%esp
        c->proc = 0;
80103d74:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103d7b:	00 00 00 
        if(!ticks) // priority boosting이 발생한 경우
80103d7e:	85 c9                	test   %ecx,%ecx
80103d80:	0f 84 57 01 00 00    	je     80103edd <scheduler+0x24d>
        if(dequeue(&mlfq.l0) != p)
80103d86:	83 ec 0c             	sub    $0xc,%esp
80103d89:	68 40 2d 11 80       	push   $0x80112d40
80103d8e:	e8 ad 3f 00 00       	call   80107d40 <dequeue>
80103d93:	83 c4 10             	add    $0x10,%esp
80103d96:	39 f8                	cmp    %edi,%eax
80103d98:	0f 85 52 02 00 00    	jne    80103ff0 <scheduler+0x360>
        if(p->lev == 1){ // tq을 다 쓴 프로세스는 l1로 넘겨줌 (이때, state에 대해서는 고려하지 않고, l1에서 처리되도록 함)
80103d9e:	8b 70 7c             	mov    0x7c(%eax),%esi
80103da1:	83 fe 01             	cmp    $0x1,%esi
80103da4:	0f 84 6e 01 00 00    	je     80103f18 <scheduler+0x288>
        else if(p->lev == 0)
80103daa:	85 f6                	test   %esi,%esi
80103dac:	0f 84 46 01 00 00    	je     80103ef8 <scheduler+0x268>
        runnable_flag = 1;
80103db2:	be 01 00 00 00       	mov    $0x1,%esi
    while(size--){
80103db7:	83 eb 01             	sub    $0x1,%ebx
80103dba:	0f 85 61 ff ff ff    	jne    80103d21 <scheduler+0x91>
    if(runnable_flag){
80103dc0:	85 f6                	test   %esi,%esi
80103dc2:	0f 85 15 01 00 00    	jne    80103edd <scheduler+0x24d>
    size = mlfq.l1.count;
80103dc8:	8b 1d 58 2e 11 80    	mov    0x80112e58,%ebx
    while(size--){ // 가장 앞에 있는 RUNNABLE한 프로세스 찾기
80103dce:	85 db                	test   %ebx,%ebx
80103dd0:	75 0b                	jne    80103ddd <scheduler+0x14d>
80103dd2:	eb 6c                	jmp    80103e40 <scheduler+0x1b0>
80103dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103dd8:	83 eb 01             	sub    $0x1,%ebx
80103ddb:	74 63                	je     80103e40 <scheduler+0x1b0>
      p = top(&mlfq.l1);
80103ddd:	83 ec 0c             	sub    $0xc,%esp
80103de0:	68 50 2e 11 80       	push   $0x80112e50
80103de5:	e8 96 3f 00 00       	call   80107d80 <top>
      if(p->lev == 1 && p->state == RUNNABLE){
80103dea:	83 c4 10             	add    $0x10,%esp
80103ded:	83 78 7c 01          	cmpl   $0x1,0x7c(%eax)
      p = top(&mlfq.l1);
80103df1:	89 c6                	mov    %eax,%esi
      if(p->lev == 1 && p->state == RUNNABLE){
80103df3:	75 0a                	jne    80103dff <scheduler+0x16f>
80103df5:	83 78 0c 03          	cmpl   $0x3,0xc(%eax)
80103df9:	0f 84 6e 01 00 00    	je     80103f6d <scheduler+0x2dd>
        dequeue(&mlfq.l1);
80103dff:	83 ec 0c             	sub    $0xc,%esp
80103e02:	68 50 2e 11 80       	push   $0x80112e50
80103e07:	e8 34 3f 00 00       	call   80107d40 <dequeue>
        if(p->lev == 1 && p->state != UNUSED && p->state != ZOMBIE)
80103e0c:	83 c4 10             	add    $0x10,%esp
80103e0f:	83 7e 7c 01          	cmpl   $0x1,0x7c(%esi)
80103e13:	75 c3                	jne    80103dd8 <scheduler+0x148>
80103e15:	8b 46 0c             	mov    0xc(%esi),%eax
80103e18:	85 c0                	test   %eax,%eax
80103e1a:	74 bc                	je     80103dd8 <scheduler+0x148>
80103e1c:	83 f8 05             	cmp    $0x5,%eax
80103e1f:	74 b7                	je     80103dd8 <scheduler+0x148>
          enqueue(&mlfq.l1, p); // RUNNABLE로 전환될 여지가 남아 있음, L1의 맨 뒤로 보냄
80103e21:	83 ec 08             	sub    $0x8,%esp
80103e24:	56                   	push   %esi
80103e25:	68 50 2e 11 80       	push   $0x80112e50
80103e2a:	e8 d1 3e 00 00       	call   80107d00 <enqueue>
80103e2f:	83 c4 10             	add    $0x10,%esp
    while(size--){ // 가장 앞에 있는 RUNNABLE한 프로세스 찾기
80103e32:	83 eb 01             	sub    $0x1,%ebx
80103e35:	75 a6                	jne    80103ddd <scheduler+0x14d>
80103e37:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103e3e:	66 90                	xchg   %ax,%ax
      int i = (mlfq.l2.front + 1) % (NPROC + 1);
80103e40:	a1 60 2f 11 80       	mov    0x80112f60,%eax
80103e45:	ba 7f e0 07 7e       	mov    $0x7e07e07f,%edx
      size = mlfq.l2.count;
80103e4a:	8b 0d 68 2f 11 80    	mov    0x80112f68,%ecx
      int i = (mlfq.l2.front + 1) % (NPROC + 1);
80103e50:	8d 58 01             	lea    0x1(%eax),%ebx
80103e53:	89 d8                	mov    %ebx,%eax
80103e55:	f7 ea                	imul   %edx
80103e57:	89 d8                	mov    %ebx,%eax
80103e59:	c1 f8 1f             	sar    $0x1f,%eax
80103e5c:	c1 fa 05             	sar    $0x5,%edx
80103e5f:	29 c2                	sub    %eax,%edx
80103e61:	89 d0                	mov    %edx,%eax
80103e63:	c1 e0 06             	shl    $0x6,%eax
80103e66:	01 d0                	add    %edx,%eax
80103e68:	89 da                	mov    %ebx,%edx
      while(size--){
80103e6a:	8d 59 ff             	lea    -0x1(%ecx),%ebx
      int i = (mlfq.l2.front + 1) % (NPROC + 1);
80103e6d:	29 c2                	sub    %eax,%edx
      while(size--){
80103e6f:	85 c9                	test   %ecx,%ecx
80103e71:	74 6a                	je     80103edd <scheduler+0x24d>
      p = NULL;
80103e73:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
      priority_min = 4; // max: 3 이므로 처음 초기화를 위해 4로 설정하고 시작함
80103e7a:	bf 04 00 00 00       	mov    $0x4,%edi
        i = (i + 1) % (NPROC + 1);
80103e7f:	be 7f e0 07 7e       	mov    $0x7e07e07f,%esi
80103e84:	eb 2b                	jmp    80103eb1 <scheduler+0x221>
80103e86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103e8d:	8d 76 00             	lea    0x0(%esi),%esi
80103e90:	8d 4a 01             	lea    0x1(%edx),%ecx
80103e93:	89 c8                	mov    %ecx,%eax
80103e95:	f7 ee                	imul   %esi
80103e97:	89 c8                	mov    %ecx,%eax
80103e99:	c1 f8 1f             	sar    $0x1f,%eax
80103e9c:	c1 fa 05             	sar    $0x5,%edx
80103e9f:	29 c2                	sub    %eax,%edx
80103ea1:	89 d0                	mov    %edx,%eax
80103ea3:	c1 e0 06             	shl    $0x6,%eax
80103ea6:	01 d0                	add    %edx,%eax
80103ea8:	29 c1                	sub    %eax,%ecx
80103eaa:	89 ca                	mov    %ecx,%edx
      while(size--){
80103eac:	83 eb 01             	sub    $0x1,%ebx
80103eaf:	72 1f                	jb     80103ed0 <scheduler+0x240>
        now = mlfq.l2.q[i];
80103eb1:	8b 04 95 6c 2f 11 80 	mov    -0x7feed094(,%edx,4),%eax
        if(now->state == RUNNABLE && now->priority < priority_min){
80103eb8:	83 78 0c 03          	cmpl   $0x3,0xc(%eax)
80103ebc:	75 d2                	jne    80103e90 <scheduler+0x200>
80103ebe:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80103ec4:	39 f9                	cmp    %edi,%ecx
80103ec6:	7d c8                	jge    80103e90 <scheduler+0x200>
80103ec8:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103ecb:	89 cf                	mov    %ecx,%edi
80103ecd:	eb c1                	jmp    80103e90 <scheduler+0x200>
80103ecf:	90                   	nop
      if(p && p->lev == 2){ // RUNNABLE한 프로세스 중 가장 우선순위가 낮은 프로세스를 찾았다면! // Unlock 이후에 lev이 변경된 프로세스 있을 수 있음
80103ed0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ed3:	85 c0                	test   %eax,%eax
80103ed5:	74 06                	je     80103edd <scheduler+0x24d>
80103ed7:	83 78 7c 02          	cmpl   $0x2,0x7c(%eax)
80103edb:	74 51                	je     80103f2e <scheduler+0x29e>
      release(&ptable.lock);
80103edd:	83 ec 0c             	sub    $0xc,%esp
80103ee0:	68 80 30 11 80       	push   $0x80113080
80103ee5:	e8 16 0e 00 00       	call   80104d00 <release>
      continue;
80103eea:	83 c4 10             	add    $0x10,%esp
80103eed:	e9 c6 fd ff ff       	jmp    80103cb8 <scheduler+0x28>
80103ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
          enqueue(&mlfq.l0, p);
80103ef8:	83 ec 08             	sub    $0x8,%esp
        runnable_flag = 1;
80103efb:	be 01 00 00 00       	mov    $0x1,%esi
          enqueue(&mlfq.l0, p);
80103f00:	50                   	push   %eax
80103f01:	68 40 2d 11 80       	push   $0x80112d40
80103f06:	e8 f5 3d 00 00       	call   80107d00 <enqueue>
80103f0b:	83 c4 10             	add    $0x10,%esp
80103f0e:	e9 05 fe ff ff       	jmp    80103d18 <scheduler+0x88>
80103f13:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103f17:	90                   	nop
          enqueue(&mlfq.l1, p);
80103f18:	83 ec 08             	sub    $0x8,%esp
80103f1b:	50                   	push   %eax
80103f1c:	68 50 2e 11 80       	push   $0x80112e50
80103f21:	e8 da 3d 00 00       	call   80107d00 <enqueue>
80103f26:	83 c4 10             	add    $0x10,%esp
80103f29:	e9 ea fd ff ff       	jmp    80103d18 <scheduler+0x88>
        c->proc = p;
80103f2e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
        switchuvm(p);
80103f31:	83 ec 0c             	sub    $0xc,%esp
        c->proc = p;
80103f34:	89 c3                	mov    %eax,%ebx
80103f36:	89 86 ac 00 00 00    	mov    %eax,0xac(%esi)
        switchuvm(p);
80103f3c:	50                   	push   %eax
80103f3d:	e8 0e 35 00 00       	call   80107450 <switchuvm>
        p->state = RUNNING;
80103f42:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
        swtch(&(c->scheduler), p->context);
80103f49:	5a                   	pop    %edx
80103f4a:	59                   	pop    %ecx
80103f4b:	ff 73 1c             	push   0x1c(%ebx)
80103f4e:	ff 75 e0             	push   -0x20(%ebp)
80103f51:	e8 e5 10 00 00       	call   8010503b <swtch>
        switchkvm();
80103f56:	e8 e5 34 00 00       	call   80107440 <switchkvm>
        c->proc = 0;
80103f5b:	83 c4 10             	add    $0x10,%esp
80103f5e:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103f65:	00 00 00 
80103f68:	e9 70 ff ff ff       	jmp    80103edd <scheduler+0x24d>
        c->proc = p;
80103f6d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
        switchuvm(p);
80103f70:	83 ec 0c             	sub    $0xc,%esp
        c->proc = p;
80103f73:	89 83 ac 00 00 00    	mov    %eax,0xac(%ebx)
        switchuvm(p);
80103f79:	50                   	push   %eax
80103f7a:	e8 d1 34 00 00       	call   80107450 <switchuvm>
        p->state = RUNNING;
80103f7f:	c7 46 0c 04 00 00 00 	movl   $0x4,0xc(%esi)
        swtch(&(c->scheduler), p->context);
80103f86:	5f                   	pop    %edi
80103f87:	58                   	pop    %eax
80103f88:	ff 76 1c             	push   0x1c(%esi)
80103f8b:	ff 75 e0             	push   -0x20(%ebp)
80103f8e:	e8 a8 10 00 00       	call   8010503b <swtch>
        switchkvm();
80103f93:	e8 a8 34 00 00       	call   80107440 <switchkvm>
        if(!ticks) // priority boosting이 발생한 경우
80103f98:	a1 c0 53 11 80       	mov    0x801153c0,%eax
80103f9d:	83 c4 10             	add    $0x10,%esp
        c->proc = 0;
80103fa0:	c7 83 ac 00 00 00 00 	movl   $0x0,0xac(%ebx)
80103fa7:	00 00 00 
        if(!ticks) // priority boosting이 발생한 경우
80103faa:	85 c0                	test   %eax,%eax
80103fac:	0f 84 2b ff ff ff    	je     80103edd <scheduler+0x24d>
        if(dequeue(&mlfq.l1) != p)
80103fb2:	83 ec 0c             	sub    $0xc,%esp
80103fb5:	68 50 2e 11 80       	push   $0x80112e50
80103fba:	e8 81 3d 00 00       	call   80107d40 <dequeue>
80103fbf:	83 c4 10             	add    $0x10,%esp
80103fc2:	39 f0                	cmp    %esi,%eax
80103fc4:	75 4c                	jne    80104012 <scheduler+0x382>
        if(p->lev == 2){ // tq을 다 쓴 프로세스는 dequeue 하고, l2로 넘겨줌
80103fc6:	8b 50 7c             	mov    0x7c(%eax),%edx
80103fc9:	83 fa 02             	cmp    $0x2,%edx
80103fcc:	74 2f                	je     80103ffd <scheduler+0x36d>
        else if(p->lev == 1)
80103fce:	83 ea 01             	sub    $0x1,%edx
80103fd1:	0f 85 06 ff ff ff    	jne    80103edd <scheduler+0x24d>
          enqueue(&mlfq.l1, p);
80103fd7:	53                   	push   %ebx
80103fd8:	53                   	push   %ebx
80103fd9:	50                   	push   %eax
80103fda:	68 50 2e 11 80       	push   $0x80112e50
80103fdf:	e8 1c 3d 00 00       	call   80107d00 <enqueue>
80103fe4:	83 c4 10             	add    $0x10,%esp
80103fe7:	e9 f1 fe ff ff       	jmp    80103edd <scheduler+0x24d>
80103fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
          panic("Unexpected modify in L0 Queue");
80103ff0:	83 ec 0c             	sub    $0xc,%esp
80103ff3:	68 3b 84 10 80       	push   $0x8010843b
80103ff8:	e8 83 c3 ff ff       	call   80100380 <panic>
          enqueue(&mlfq.l2, p);
80103ffd:	56                   	push   %esi
80103ffe:	56                   	push   %esi
80103fff:	50                   	push   %eax
80104000:	68 60 2f 11 80       	push   $0x80112f60
80104005:	e8 f6 3c 00 00       	call   80107d00 <enqueue>
8010400a:	83 c4 10             	add    $0x10,%esp
8010400d:	e9 cb fe ff ff       	jmp    80103edd <scheduler+0x24d>
          panic("Unexpected modify in L1 Queue");
80104012:	83 ec 0c             	sub    $0xc,%esp
80104015:	68 59 84 10 80       	push   $0x80108459
8010401a:	e8 61 c3 ff ff       	call   80100380 <panic>
8010401f:	90                   	nop

80104020 <sched>:
{
80104020:	55                   	push   %ebp
80104021:	89 e5                	mov    %esp,%ebp
80104023:	56                   	push   %esi
80104024:	53                   	push   %ebx
  pushcli();
80104025:	e8 e6 0b 00 00       	call   80104c10 <pushcli>
  c = mycpu();
8010402a:	e8 21 f9 ff ff       	call   80103950 <mycpu>
  p = c->proc;
8010402f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104035:	e8 26 0c 00 00       	call   80104c60 <popcli>
  if(!holding(&ptable.lock))
8010403a:	83 ec 0c             	sub    $0xc,%esp
8010403d:	68 80 30 11 80       	push   $0x80113080
80104042:	e8 79 0c 00 00       	call   80104cc0 <holding>
80104047:	83 c4 10             	add    $0x10,%esp
8010404a:	85 c0                	test   %eax,%eax
8010404c:	74 4f                	je     8010409d <sched+0x7d>
  if(mycpu()->ncli != 1)
8010404e:	e8 fd f8 ff ff       	call   80103950 <mycpu>
80104053:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010405a:	75 68                	jne    801040c4 <sched+0xa4>
  if(p->state == RUNNING)
8010405c:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80104060:	74 55                	je     801040b7 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104062:	9c                   	pushf  
80104063:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104064:	f6 c4 02             	test   $0x2,%ah
80104067:	75 41                	jne    801040aa <sched+0x8a>
  intena = mycpu()->intena;
80104069:	e8 e2 f8 ff ff       	call   80103950 <mycpu>
  swtch(&p->context, mycpu()->scheduler); // 프로세스에서 스케줄러로
8010406e:	83 c3 1c             	add    $0x1c,%ebx
  intena = mycpu()->intena;
80104071:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler); // 프로세스에서 스케줄러로
80104077:	e8 d4 f8 ff ff       	call   80103950 <mycpu>
8010407c:	83 ec 08             	sub    $0x8,%esp
8010407f:	ff 70 04             	push   0x4(%eax)
80104082:	53                   	push   %ebx
80104083:	e8 b3 0f 00 00       	call   8010503b <swtch>
  mycpu()->intena = intena;
80104088:	e8 c3 f8 ff ff       	call   80103950 <mycpu>
}
8010408d:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104090:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80104096:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104099:	5b                   	pop    %ebx
8010409a:	5e                   	pop    %esi
8010409b:	5d                   	pop    %ebp
8010409c:	c3                   	ret    
    panic("sched ptable.lock");
8010409d:	83 ec 0c             	sub    $0xc,%esp
801040a0:	68 77 84 10 80       	push   $0x80108477
801040a5:	e8 d6 c2 ff ff       	call   80100380 <panic>
    panic("sched interruptible");
801040aa:	83 ec 0c             	sub    $0xc,%esp
801040ad:	68 a3 84 10 80       	push   $0x801084a3
801040b2:	e8 c9 c2 ff ff       	call   80100380 <panic>
    panic("sched running");
801040b7:	83 ec 0c             	sub    $0xc,%esp
801040ba:	68 95 84 10 80       	push   $0x80108495
801040bf:	e8 bc c2 ff ff       	call   80100380 <panic>
    panic("sched locks");
801040c4:	83 ec 0c             	sub    $0xc,%esp
801040c7:	68 89 84 10 80       	push   $0x80108489
801040cc:	e8 af c2 ff ff       	call   80100380 <panic>
801040d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040df:	90                   	nop

801040e0 <exit>:
{
801040e0:	55                   	push   %ebp
801040e1:	89 e5                	mov    %esp,%ebp
801040e3:	57                   	push   %edi
801040e4:	56                   	push   %esi
801040e5:	53                   	push   %ebx
801040e6:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
801040e9:	e8 e2 f8 ff ff       	call   801039d0 <myproc>
  if(curproc == initproc)
801040ee:	39 05 b4 53 11 80    	cmp    %eax,0x801153b4
801040f4:	0f 84 07 01 00 00    	je     80104201 <exit+0x121>
801040fa:	89 c3                	mov    %eax,%ebx
801040fc:	8d 70 28             	lea    0x28(%eax),%esi
801040ff:	8d 78 68             	lea    0x68(%eax),%edi
80104102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[fd]){
80104108:	8b 06                	mov    (%esi),%eax
8010410a:	85 c0                	test   %eax,%eax
8010410c:	74 12                	je     80104120 <exit+0x40>
      fileclose(curproc->ofile[fd]);
8010410e:	83 ec 0c             	sub    $0xc,%esp
80104111:	50                   	push   %eax
80104112:	e8 d9 cd ff ff       	call   80100ef0 <fileclose>
      curproc->ofile[fd] = 0;
80104117:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010411d:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80104120:	83 c6 04             	add    $0x4,%esi
80104123:	39 f7                	cmp    %esi,%edi
80104125:	75 e1                	jne    80104108 <exit+0x28>
  begin_op();
80104127:	e8 34 ec ff ff       	call   80102d60 <begin_op>
  iput(curproc->cwd);
8010412c:	83 ec 0c             	sub    $0xc,%esp
8010412f:	ff 73 68             	push   0x68(%ebx)
80104132:	e8 79 d7 ff ff       	call   801018b0 <iput>
  end_op();
80104137:	e8 94 ec ff ff       	call   80102dd0 <end_op>
  curproc->cwd = 0;
8010413c:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
  acquire(&ptable.lock);
80104143:	c7 04 24 80 30 11 80 	movl   $0x80113080,(%esp)
8010414a:	e8 11 0c 00 00       	call   80104d60 <acquire>
  wakeup1(curproc->parent);
8010414f:	8b 53 14             	mov    0x14(%ebx),%edx
80104152:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104155:	b8 b4 30 11 80       	mov    $0x801130b4,%eax
8010415a:	eb 10                	jmp    8010416c <exit+0x8c>
8010415c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104160:	05 8c 00 00 00       	add    $0x8c,%eax
80104165:	3d b4 53 11 80       	cmp    $0x801153b4,%eax
8010416a:	74 1e                	je     8010418a <exit+0xaa>
    if(p->state == SLEEPING && p->chan == chan)
8010416c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104170:	75 ee                	jne    80104160 <exit+0x80>
80104172:	3b 50 20             	cmp    0x20(%eax),%edx
80104175:	75 e9                	jne    80104160 <exit+0x80>
      p->state = RUNNABLE;
80104177:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010417e:	05 8c 00 00 00       	add    $0x8c,%eax
80104183:	3d b4 53 11 80       	cmp    $0x801153b4,%eax
80104188:	75 e2                	jne    8010416c <exit+0x8c>
      p->parent = initproc;
8010418a:	8b 0d b4 53 11 80    	mov    0x801153b4,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104190:	ba b4 30 11 80       	mov    $0x801130b4,%edx
80104195:	eb 17                	jmp    801041ae <exit+0xce>
80104197:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010419e:	66 90                	xchg   %ax,%ax
801041a0:	81 c2 8c 00 00 00    	add    $0x8c,%edx
801041a6:	81 fa b4 53 11 80    	cmp    $0x801153b4,%edx
801041ac:	74 3a                	je     801041e8 <exit+0x108>
    if(p->parent == curproc){
801041ae:	39 5a 14             	cmp    %ebx,0x14(%edx)
801041b1:	75 ed                	jne    801041a0 <exit+0xc0>
      if(p->state == ZOMBIE)
801041b3:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
      p->parent = initproc;
801041b7:	89 4a 14             	mov    %ecx,0x14(%edx)
      if(p->state == ZOMBIE)
801041ba:	75 e4                	jne    801041a0 <exit+0xc0>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041bc:	b8 b4 30 11 80       	mov    $0x801130b4,%eax
801041c1:	eb 11                	jmp    801041d4 <exit+0xf4>
801041c3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801041c7:	90                   	nop
801041c8:	05 8c 00 00 00       	add    $0x8c,%eax
801041cd:	3d b4 53 11 80       	cmp    $0x801153b4,%eax
801041d2:	74 cc                	je     801041a0 <exit+0xc0>
    if(p->state == SLEEPING && p->chan == chan)
801041d4:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801041d8:	75 ee                	jne    801041c8 <exit+0xe8>
801041da:	3b 48 20             	cmp    0x20(%eax),%ecx
801041dd:	75 e9                	jne    801041c8 <exit+0xe8>
      p->state = RUNNABLE;
801041df:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801041e6:	eb e0                	jmp    801041c8 <exit+0xe8>
  curproc->state = ZOMBIE;
801041e8:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
801041ef:	e8 2c fe ff ff       	call   80104020 <sched>
  panic("zombie exit");
801041f4:	83 ec 0c             	sub    $0xc,%esp
801041f7:	68 c4 84 10 80       	push   $0x801084c4
801041fc:	e8 7f c1 ff ff       	call   80100380 <panic>
    panic("init exiting");
80104201:	83 ec 0c             	sub    $0xc,%esp
80104204:	68 b7 84 10 80       	push   $0x801084b7
80104209:	e8 72 c1 ff ff       	call   80100380 <panic>
8010420e:	66 90                	xchg   %ax,%ax

80104210 <wait>:
{
80104210:	55                   	push   %ebp
80104211:	89 e5                	mov    %esp,%ebp
80104213:	56                   	push   %esi
80104214:	53                   	push   %ebx
  pushcli();
80104215:	e8 f6 09 00 00       	call   80104c10 <pushcli>
  c = mycpu();
8010421a:	e8 31 f7 ff ff       	call   80103950 <mycpu>
  p = c->proc;
8010421f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80104225:	e8 36 0a 00 00       	call   80104c60 <popcli>
  acquire(&ptable.lock);
8010422a:	83 ec 0c             	sub    $0xc,%esp
8010422d:	68 80 30 11 80       	push   $0x80113080
80104232:	e8 29 0b 00 00       	call   80104d60 <acquire>
80104237:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010423a:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010423c:	bb b4 30 11 80       	mov    $0x801130b4,%ebx
80104241:	eb 13                	jmp    80104256 <wait+0x46>
80104243:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104247:	90                   	nop
80104248:	81 c3 8c 00 00 00    	add    $0x8c,%ebx
8010424e:	81 fb b4 53 11 80    	cmp    $0x801153b4,%ebx
80104254:	74 1e                	je     80104274 <wait+0x64>
      if(p->parent != curproc)
80104256:	39 73 14             	cmp    %esi,0x14(%ebx)
80104259:	75 ed                	jne    80104248 <wait+0x38>
      if(p->state == ZOMBIE){
8010425b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010425f:	74 5f                	je     801042c0 <wait+0xb0>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104261:	81 c3 8c 00 00 00    	add    $0x8c,%ebx
      havekids = 1;
80104267:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010426c:	81 fb b4 53 11 80    	cmp    $0x801153b4,%ebx
80104272:	75 e2                	jne    80104256 <wait+0x46>
    if(!havekids || curproc->killed){
80104274:	85 c0                	test   %eax,%eax
80104276:	0f 84 bf 00 00 00    	je     8010433b <wait+0x12b>
8010427c:	8b 46 24             	mov    0x24(%esi),%eax
8010427f:	85 c0                	test   %eax,%eax
80104281:	0f 85 b4 00 00 00    	jne    8010433b <wait+0x12b>
  pushcli();
80104287:	e8 84 09 00 00       	call   80104c10 <pushcli>
  c = mycpu();
8010428c:	e8 bf f6 ff ff       	call   80103950 <mycpu>
  p = c->proc;
80104291:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104297:	e8 c4 09 00 00       	call   80104c60 <popcli>
  if(p == 0)
8010429c:	85 db                	test   %ebx,%ebx
8010429e:	0f 84 ae 00 00 00    	je     80104352 <wait+0x142>
  p->chan = chan;
801042a4:	89 73 20             	mov    %esi,0x20(%ebx)
  p->state = SLEEPING;
801042a7:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
801042ae:	e8 6d fd ff ff       	call   80104020 <sched>
  p->chan = 0;
801042b3:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
801042ba:	e9 7b ff ff ff       	jmp    8010423a <wait+0x2a>
801042bf:	90                   	nop
        kfree(p->kstack);
801042c0:	83 ec 0c             	sub    $0xc,%esp
        pid = p->pid;
801042c3:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801042c6:	ff 73 08             	push   0x8(%ebx)
801042c9:	e8 f2 e1 ff ff       	call   801024c0 <kfree>
        p->kstack = 0;
801042ce:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801042d5:	5a                   	pop    %edx
801042d6:	ff 73 04             	push   0x4(%ebx)
801042d9:	e8 52 35 00 00       	call   80107830 <freevm>
        p->pid = 0;
801042de:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801042e5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801042ec:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801042f0:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801042f7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        p->lev = 0;
801042fe:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
        p->tq = 0;
80104305:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
8010430c:	00 00 00 
        p->priority = 3;
8010430f:	c7 83 84 00 00 00 03 	movl   $0x3,0x84(%ebx)
80104316:	00 00 00 
        p->locked = 0;
80104319:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
80104320:	00 00 00 
        release(&ptable.lock);
80104323:	c7 04 24 80 30 11 80 	movl   $0x80113080,(%esp)
8010432a:	e8 d1 09 00 00       	call   80104d00 <release>
        return pid;
8010432f:	83 c4 10             	add    $0x10,%esp
}
80104332:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104335:	89 f0                	mov    %esi,%eax
80104337:	5b                   	pop    %ebx
80104338:	5e                   	pop    %esi
80104339:	5d                   	pop    %ebp
8010433a:	c3                   	ret    
      release(&ptable.lock);
8010433b:	83 ec 0c             	sub    $0xc,%esp
      return -1;
8010433e:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
80104343:	68 80 30 11 80       	push   $0x80113080
80104348:	e8 b3 09 00 00       	call   80104d00 <release>
      return -1;
8010434d:	83 c4 10             	add    $0x10,%esp
80104350:	eb e0                	jmp    80104332 <wait+0x122>
    panic("sleep");
80104352:	83 ec 0c             	sub    $0xc,%esp
80104355:	68 d0 84 10 80       	push   $0x801084d0
8010435a:	e8 21 c0 ff ff       	call   80100380 <panic>
8010435f:	90                   	nop

80104360 <yield>:
{
80104360:	55                   	push   %ebp
80104361:	89 e5                	mov    %esp,%ebp
80104363:	53                   	push   %ebx
80104364:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104367:	68 80 30 11 80       	push   $0x80113080
8010436c:	e8 ef 09 00 00       	call   80104d60 <acquire>
  pushcli();
80104371:	e8 9a 08 00 00       	call   80104c10 <pushcli>
  c = mycpu();
80104376:	e8 d5 f5 ff ff       	call   80103950 <mycpu>
  p = c->proc;
8010437b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104381:	e8 da 08 00 00       	call   80104c60 <popcli>
  myproc()->state = RUNNABLE; //실행 중인 프로세스를 RUNNABLE 상태로 전환시킴
80104386:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched(); // switch to scheduler
8010438d:	e8 8e fc ff ff       	call   80104020 <sched>
  release(&ptable.lock);
80104392:	c7 04 24 80 30 11 80 	movl   $0x80113080,(%esp)
80104399:	e8 62 09 00 00       	call   80104d00 <release>
}
8010439e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043a1:	83 c4 10             	add    $0x10,%esp
801043a4:	c9                   	leave  
801043a5:	c3                   	ret    
801043a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801043ad:	8d 76 00             	lea    0x0(%esi),%esi

801043b0 <sleep>:
{
801043b0:	55                   	push   %ebp
801043b1:	89 e5                	mov    %esp,%ebp
801043b3:	57                   	push   %edi
801043b4:	56                   	push   %esi
801043b5:	53                   	push   %ebx
801043b6:	83 ec 0c             	sub    $0xc,%esp
801043b9:	8b 7d 08             	mov    0x8(%ebp),%edi
801043bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
801043bf:	e8 4c 08 00 00       	call   80104c10 <pushcli>
  c = mycpu();
801043c4:	e8 87 f5 ff ff       	call   80103950 <mycpu>
  p = c->proc;
801043c9:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801043cf:	e8 8c 08 00 00       	call   80104c60 <popcli>
  if(p == 0)
801043d4:	85 db                	test   %ebx,%ebx
801043d6:	0f 84 87 00 00 00    	je     80104463 <sleep+0xb3>
  if(lk == 0)
801043dc:	85 f6                	test   %esi,%esi
801043de:	74 76                	je     80104456 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801043e0:	81 fe 80 30 11 80    	cmp    $0x80113080,%esi
801043e6:	74 50                	je     80104438 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
801043e8:	83 ec 0c             	sub    $0xc,%esp
801043eb:	68 80 30 11 80       	push   $0x80113080
801043f0:	e8 6b 09 00 00       	call   80104d60 <acquire>
    release(lk);
801043f5:	89 34 24             	mov    %esi,(%esp)
801043f8:	e8 03 09 00 00       	call   80104d00 <release>
  p->chan = chan;
801043fd:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80104400:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104407:	e8 14 fc ff ff       	call   80104020 <sched>
  p->chan = 0;
8010440c:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
    release(&ptable.lock);
80104413:	c7 04 24 80 30 11 80 	movl   $0x80113080,(%esp)
8010441a:	e8 e1 08 00 00       	call   80104d00 <release>
    acquire(lk);
8010441f:	89 75 08             	mov    %esi,0x8(%ebp)
80104422:	83 c4 10             	add    $0x10,%esp
}
80104425:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104428:	5b                   	pop    %ebx
80104429:	5e                   	pop    %esi
8010442a:	5f                   	pop    %edi
8010442b:	5d                   	pop    %ebp
    acquire(lk);
8010442c:	e9 2f 09 00 00       	jmp    80104d60 <acquire>
80104431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
80104438:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
8010443b:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104442:	e8 d9 fb ff ff       	call   80104020 <sched>
  p->chan = 0;
80104447:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
8010444e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104451:	5b                   	pop    %ebx
80104452:	5e                   	pop    %esi
80104453:	5f                   	pop    %edi
80104454:	5d                   	pop    %ebp
80104455:	c3                   	ret    
    panic("sleep without lk");
80104456:	83 ec 0c             	sub    $0xc,%esp
80104459:	68 d6 84 10 80       	push   $0x801084d6
8010445e:	e8 1d bf ff ff       	call   80100380 <panic>
    panic("sleep");
80104463:	83 ec 0c             	sub    $0xc,%esp
80104466:	68 d0 84 10 80       	push   $0x801084d0
8010446b:	e8 10 bf ff ff       	call   80100380 <panic>

80104470 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104470:	55                   	push   %ebp
80104471:	89 e5                	mov    %esp,%ebp
80104473:	53                   	push   %ebx
80104474:	83 ec 10             	sub    $0x10,%esp
80104477:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010447a:	68 80 30 11 80       	push   $0x80113080
8010447f:	e8 dc 08 00 00       	call   80104d60 <acquire>
80104484:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104487:	b8 b4 30 11 80       	mov    $0x801130b4,%eax
8010448c:	eb 0e                	jmp    8010449c <wakeup+0x2c>
8010448e:	66 90                	xchg   %ax,%ax
80104490:	05 8c 00 00 00       	add    $0x8c,%eax
80104495:	3d b4 53 11 80       	cmp    $0x801153b4,%eax
8010449a:	74 1e                	je     801044ba <wakeup+0x4a>
    if(p->state == SLEEPING && p->chan == chan)
8010449c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801044a0:	75 ee                	jne    80104490 <wakeup+0x20>
801044a2:	3b 58 20             	cmp    0x20(%eax),%ebx
801044a5:	75 e9                	jne    80104490 <wakeup+0x20>
      p->state = RUNNABLE;
801044a7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044ae:	05 8c 00 00 00       	add    $0x8c,%eax
801044b3:	3d b4 53 11 80       	cmp    $0x801153b4,%eax
801044b8:	75 e2                	jne    8010449c <wakeup+0x2c>
  wakeup1(chan);
  release(&ptable.lock);
801044ba:	c7 45 08 80 30 11 80 	movl   $0x80113080,0x8(%ebp)
}
801044c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044c4:	c9                   	leave  
  release(&ptable.lock);
801044c5:	e9 36 08 00 00       	jmp    80104d00 <release>
801044ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801044d0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801044d0:	55                   	push   %ebp
801044d1:	89 e5                	mov    %esp,%ebp
801044d3:	53                   	push   %ebx
801044d4:	83 ec 10             	sub    $0x10,%esp
801044d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801044da:	68 80 30 11 80       	push   $0x80113080
801044df:	e8 7c 08 00 00       	call   80104d60 <acquire>
801044e4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044e7:	b8 b4 30 11 80       	mov    $0x801130b4,%eax
801044ec:	eb 0e                	jmp    801044fc <kill+0x2c>
801044ee:	66 90                	xchg   %ax,%ax
801044f0:	05 8c 00 00 00       	add    $0x8c,%eax
801044f5:	3d b4 53 11 80       	cmp    $0x801153b4,%eax
801044fa:	74 34                	je     80104530 <kill+0x60>
    if(p->pid == pid){
801044fc:	39 58 10             	cmp    %ebx,0x10(%eax)
801044ff:	75 ef                	jne    801044f0 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104501:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
80104505:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010450c:	75 07                	jne    80104515 <kill+0x45>
        p->state = RUNNABLE;
8010450e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104515:	83 ec 0c             	sub    $0xc,%esp
80104518:	68 80 30 11 80       	push   $0x80113080
8010451d:	e8 de 07 00 00       	call   80104d00 <release>
      return 0; // 프로세스를 exit (종료) 시키기 위해 return ! 정상종료: 0
    }
  }
  release(&ptable.lock);
  return -1;
}
80104522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0; // 프로세스를 exit (종료) 시키기 위해 return ! 정상종료: 0
80104525:	83 c4 10             	add    $0x10,%esp
80104528:	31 c0                	xor    %eax,%eax
}
8010452a:	c9                   	leave  
8010452b:	c3                   	ret    
8010452c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&ptable.lock);
80104530:	83 ec 0c             	sub    $0xc,%esp
80104533:	68 80 30 11 80       	push   $0x80113080
80104538:	e8 c3 07 00 00       	call   80104d00 <release>
}
8010453d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104540:	83 c4 10             	add    $0x10,%esp
80104543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104548:	c9                   	leave  
80104549:	c3                   	ret    
8010454a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104550 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104550:	55                   	push   %ebp
80104551:	89 e5                	mov    %esp,%ebp
80104553:	57                   	push   %edi
80104554:	56                   	push   %esi
80104555:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104558:	53                   	push   %ebx
80104559:	bb 20 31 11 80       	mov    $0x80113120,%ebx
8010455e:	83 ec 3c             	sub    $0x3c,%esp
80104561:	eb 27                	jmp    8010458a <procdump+0x3a>
80104563:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104567:	90                   	nop
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104568:	83 ec 0c             	sub    $0xc,%esp
8010456b:	68 70 87 10 80       	push   $0x80108770
80104570:	e8 2b c1 ff ff       	call   801006a0 <cprintf>
80104575:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104578:	81 c3 8c 00 00 00    	add    $0x8c,%ebx
8010457e:	81 fb 20 54 11 80    	cmp    $0x80115420,%ebx
80104584:	0f 84 7e 00 00 00    	je     80104608 <procdump+0xb8>
    if(p->state == UNUSED)
8010458a:	8b 43 a0             	mov    -0x60(%ebx),%eax
8010458d:	85 c0                	test   %eax,%eax
8010458f:	74 e7                	je     80104578 <procdump+0x28>
      state = "???";
80104591:	ba e7 84 10 80       	mov    $0x801084e7,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104596:	83 f8 05             	cmp    $0x5,%eax
80104599:	77 11                	ja     801045ac <procdump+0x5c>
8010459b:	8b 14 85 f4 85 10 80 	mov    -0x7fef7a0c(,%eax,4),%edx
      state = "???";
801045a2:	b8 e7 84 10 80       	mov    $0x801084e7,%eax
801045a7:	85 d2                	test   %edx,%edx
801045a9:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
801045ac:	53                   	push   %ebx
801045ad:	52                   	push   %edx
801045ae:	ff 73 a4             	push   -0x5c(%ebx)
801045b1:	68 eb 84 10 80       	push   $0x801084eb
801045b6:	e8 e5 c0 ff ff       	call   801006a0 <cprintf>
    if(p->state == SLEEPING){
801045bb:	83 c4 10             	add    $0x10,%esp
801045be:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
801045c2:	75 a4                	jne    80104568 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801045c4:	83 ec 08             	sub    $0x8,%esp
801045c7:	8d 45 c0             	lea    -0x40(%ebp),%eax
801045ca:	8d 7d c0             	lea    -0x40(%ebp),%edi
801045cd:	50                   	push   %eax
801045ce:	8b 43 b0             	mov    -0x50(%ebx),%eax
801045d1:	8b 40 0c             	mov    0xc(%eax),%eax
801045d4:	83 c0 08             	add    $0x8,%eax
801045d7:	50                   	push   %eax
801045d8:	e8 d3 05 00 00       	call   80104bb0 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801045dd:	83 c4 10             	add    $0x10,%esp
801045e0:	8b 17                	mov    (%edi),%edx
801045e2:	85 d2                	test   %edx,%edx
801045e4:	74 82                	je     80104568 <procdump+0x18>
        cprintf(" %p", pc[i]);
801045e6:	83 ec 08             	sub    $0x8,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801045e9:	83 c7 04             	add    $0x4,%edi
        cprintf(" %p", pc[i]);
801045ec:	52                   	push   %edx
801045ed:	68 01 7f 10 80       	push   $0x80107f01
801045f2:	e8 a9 c0 ff ff       	call   801006a0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801045f7:	83 c4 10             	add    $0x10,%esp
801045fa:	39 fe                	cmp    %edi,%esi
801045fc:	75 e2                	jne    801045e0 <procdump+0x90>
801045fe:	e9 65 ff ff ff       	jmp    80104568 <procdump+0x18>
80104603:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104607:	90                   	nop
  }
}
80104608:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010460b:	5b                   	pop    %ebx
8010460c:	5e                   	pop    %esi
8010460d:	5f                   	pop    %edi
8010460e:	5d                   	pop    %ebp
8010460f:	c3                   	ret    

80104610 <priorityBoosting>:
// tq=0, lev=0, priority=3으로 재설정
// 큐 순서를 유지하되 현재 레벨이 높은 순서대로
// UNUSED 된 프로세스 정리
void
priorityBoosting(void)
{
80104610:	55                   	push   %ebp
80104611:	89 e5                	mov    %esp,%ebp
80104613:	53                   	push   %ebx
80104614:	83 ec 04             	sub    $0x4,%esp
  struct proc *p;
  int size;

  pushcli(); // disable timer interrupts
80104617:	e8 f4 05 00 00       	call   80104c10 <pushcli>
  acquire(&ptable.lock);
8010461c:	83 ec 0c             	sub    $0xc,%esp
8010461f:	68 80 30 11 80       	push   $0x80113080
80104624:	e8 37 07 00 00       	call   80104d60 <acquire>
  size = mlfq.l0.count;
80104629:	8b 1d 48 2d 11 80    	mov    0x80112d48,%ebx
  while(size--){
8010462f:	83 c4 10             	add    $0x10,%esp
80104632:	85 db                	test   %ebx,%ebx
80104634:	74 5a                	je     80104690 <priorityBoosting+0x80>
80104636:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010463d:	8d 76 00             	lea    0x0(%esi),%esi
    p = dequeue(&mlfq.l0);
80104640:	83 ec 0c             	sub    $0xc,%esp
80104643:	68 40 2d 11 80       	push   $0x80112d40
80104648:	e8 f3 36 00 00       	call   80107d40 <dequeue>
    if(p->state != UNUSED && p->state != ZOMBIE){
8010464d:	83 c4 10             	add    $0x10,%esp
80104650:	8b 50 0c             	mov    0xc(%eax),%edx
80104653:	85 d2                	test   %edx,%edx
80104655:	74 31                	je     80104688 <priorityBoosting+0x78>
80104657:	83 fa 05             	cmp    $0x5,%edx
8010465a:	74 2c                	je     80104688 <priorityBoosting+0x78>
      p->tq = 0;
      p->lev = 0;
      p->priority = 3;
      enqueue(&mlfq.l0, p);
8010465c:	83 ec 08             	sub    $0x8,%esp
      p->tq = 0;
8010465f:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104666:	00 00 00 
      p->lev = 0;
80104669:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
      p->priority = 3;
80104670:	c7 80 84 00 00 00 03 	movl   $0x3,0x84(%eax)
80104677:	00 00 00 
      enqueue(&mlfq.l0, p);
8010467a:	50                   	push   %eax
8010467b:	68 40 2d 11 80       	push   $0x80112d40
80104680:	e8 7b 36 00 00       	call   80107d00 <enqueue>
80104685:	83 c4 10             	add    $0x10,%esp
  while(size--){
80104688:	83 eb 01             	sub    $0x1,%ebx
8010468b:	75 b3                	jne    80104640 <priorityBoosting+0x30>
8010468d:	8d 76 00             	lea    0x0(%esi),%esi
    }
  }
  while(!isEmpty(&mlfq.l1)){
80104690:	83 ec 0c             	sub    $0xc,%esp
80104693:	68 50 2e 11 80       	push   $0x80112e50
80104698:	e8 03 36 00 00       	call   80107ca0 <isEmpty>
8010469d:	83 c4 10             	add    $0x10,%esp
801046a0:	85 c0                	test   %eax,%eax
801046a2:	75 64                	jne    80104708 <priorityBoosting+0xf8>
    p = dequeue(&mlfq.l1);
801046a4:	83 ec 0c             	sub    $0xc,%esp
801046a7:	68 50 2e 11 80       	push   $0x80112e50
801046ac:	e8 8f 36 00 00       	call   80107d40 <dequeue>
    if(p->lev == 1 && p->state != UNUSED && p->state != ZOMBIE){
801046b1:	83 c4 10             	add    $0x10,%esp
801046b4:	83 78 7c 01          	cmpl   $0x1,0x7c(%eax)
801046b8:	75 d6                	jne    80104690 <priorityBoosting+0x80>
801046ba:	8b 50 0c             	mov    0xc(%eax),%edx
801046bd:	83 fa 05             	cmp    $0x5,%edx
801046c0:	74 ce                	je     80104690 <priorityBoosting+0x80>
801046c2:	85 d2                	test   %edx,%edx
801046c4:	74 ca                	je     80104690 <priorityBoosting+0x80>
      p->tq = 0;
      p->lev = 0;
      p->priority = 3;
      enqueue(&mlfq.l0, p);
801046c6:	83 ec 08             	sub    $0x8,%esp
      p->tq = 0;
801046c9:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801046d0:	00 00 00 
      p->lev = 0;
801046d3:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
      p->priority = 3;
801046da:	c7 80 84 00 00 00 03 	movl   $0x3,0x84(%eax)
801046e1:	00 00 00 
      enqueue(&mlfq.l0, p);
801046e4:	50                   	push   %eax
801046e5:	68 40 2d 11 80       	push   $0x80112d40
801046ea:	e8 11 36 00 00       	call   80107d00 <enqueue>
801046ef:	83 c4 10             	add    $0x10,%esp
801046f2:	eb 9c                	jmp    80104690 <priorityBoosting+0x80>
801046f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }
  while(!isEmpty(&mlfq.l2)){
    p = dequeue(&mlfq.l2);
    if(p->lev == 2 && p->state != UNUSED && p->state != ZOMBIE){
801046f8:	8b 50 0c             	mov    0xc(%eax),%edx
801046fb:	83 fa 05             	cmp    $0x5,%edx
801046fe:	74 08                	je     80104708 <priorityBoosting+0xf8>
80104700:	85 d2                	test   %edx,%edx
80104702:	75 34                	jne    80104738 <priorityBoosting+0x128>
80104704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(!isEmpty(&mlfq.l2)){
80104708:	83 ec 0c             	sub    $0xc,%esp
8010470b:	68 60 2f 11 80       	push   $0x80112f60
80104710:	e8 8b 35 00 00       	call   80107ca0 <isEmpty>
80104715:	83 c4 10             	add    $0x10,%esp
80104718:	85 c0                	test   %eax,%eax
8010471a:	75 54                	jne    80104770 <priorityBoosting+0x160>
    p = dequeue(&mlfq.l2);
8010471c:	83 ec 0c             	sub    $0xc,%esp
8010471f:	68 60 2f 11 80       	push   $0x80112f60
80104724:	e8 17 36 00 00       	call   80107d40 <dequeue>
    if(p->lev == 2 && p->state != UNUSED && p->state != ZOMBIE){
80104729:	83 c4 10             	add    $0x10,%esp
8010472c:	83 78 7c 02          	cmpl   $0x2,0x7c(%eax)
80104730:	75 d6                	jne    80104708 <priorityBoosting+0xf8>
80104732:	eb c4                	jmp    801046f8 <priorityBoosting+0xe8>
80104734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      p->tq = 0;
      p->lev = 0;
      p->priority = 3;
      enqueue(&mlfq.l0, p);
80104738:	83 ec 08             	sub    $0x8,%esp
      p->tq = 0;
8010473b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104742:	00 00 00 
      p->lev = 0;
80104745:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
      p->priority = 3;
8010474c:	c7 80 84 00 00 00 03 	movl   $0x3,0x84(%eax)
80104753:	00 00 00 
      enqueue(&mlfq.l0, p);
80104756:	50                   	push   %eax
80104757:	68 40 2d 11 80       	push   $0x80112d40
8010475c:	e8 9f 35 00 00       	call   80107d00 <enqueue>
80104761:	83 c4 10             	add    $0x10,%esp
80104764:	eb a2                	jmp    80104708 <priorityBoosting+0xf8>
80104766:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010476d:	8d 76 00             	lea    0x0(%esi),%esi
    }
  }
  release(&ptable.lock);
80104770:	83 ec 0c             	sub    $0xc,%esp
80104773:	68 80 30 11 80       	push   $0x80113080
80104778:	e8 83 05 00 00       	call   80104d00 <release>
  ticks = 0;
  popcli(); // enable timer interrupts
}
8010477d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  popcli(); // enable timer interrupts
80104780:	83 c4 10             	add    $0x10,%esp
  ticks = 0;
80104783:	c7 05 c0 53 11 80 00 	movl   $0x0,0x801153c0
8010478a:	00 00 00 
}
8010478d:	c9                   	leave  
  popcli(); // enable timer interrupts
8010478e:	e9 cd 04 00 00       	jmp    80104c60 <popcli>
80104793:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010479a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801047a0 <getLevel>:

// New system calls
int
getLevel(void)
{
801047a0:	55                   	push   %ebp
801047a1:	89 e5                	mov    %esp,%ebp
801047a3:	53                   	push   %ebx
801047a4:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801047a7:	e8 64 04 00 00       	call   80104c10 <pushcli>
  c = mycpu();
801047ac:	e8 9f f1 ff ff       	call   80103950 <mycpu>
  p = c->proc;
801047b1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801047b7:	e8 a4 04 00 00       	call   80104c60 <popcli>
  return myproc()->lev;
801047bc:	8b 43 7c             	mov    0x7c(%ebx),%eax
}
801047bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047c2:	c9                   	leave  
801047c3:	c3                   	ret    
801047c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801047cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801047cf:	90                   	nop

801047d0 <setPriority>:

void
setPriority(int pid, int priority)
{
801047d0:	55                   	push   %ebp
801047d1:	89 e5                	mov    %esp,%ebp
801047d3:	56                   	push   %esi
801047d4:	53                   	push   %ebx
801047d5:	8b 75 0c             	mov    0xc(%ebp),%esi
801047d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801047db:	83 ec 0c             	sub    $0xc,%esp
801047de:	68 80 30 11 80       	push   $0x80113080
801047e3:	e8 78 05 00 00       	call   80104d60 <acquire>
801047e8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047eb:	b8 b4 30 11 80       	mov    $0x801130b4,%eax
801047f0:	eb 12                	jmp    80104804 <setPriority+0x34>
801047f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801047f8:	05 8c 00 00 00       	add    $0x8c,%eax
801047fd:	3d b4 53 11 80       	cmp    $0x801153b4,%eax
80104802:	74 24                	je     80104828 <setPriority+0x58>
    if(p->pid == pid){
80104804:	39 58 10             	cmp    %ebx,0x10(%eax)
80104807:	75 ef                	jne    801047f8 <setPriority+0x28>
      p->priority = priority;
80104809:	89 b0 84 00 00 00    	mov    %esi,0x84(%eax)
      release(&ptable.lock);
8010480f:	c7 45 08 80 30 11 80 	movl   $0x80113080,0x8(%ebp)
    }
  }
  // invalid pid
  release(&ptable.lock);
  panic("setPriority: Wrong pid!");
}
80104816:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104819:	5b                   	pop    %ebx
8010481a:	5e                   	pop    %esi
8010481b:	5d                   	pop    %ebp
      release(&ptable.lock);
8010481c:	e9 df 04 00 00       	jmp    80104d00 <release>
80104821:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  release(&ptable.lock);
80104828:	83 ec 0c             	sub    $0xc,%esp
8010482b:	68 80 30 11 80       	push   $0x80113080
80104830:	e8 cb 04 00 00       	call   80104d00 <release>
  panic("setPriority: Wrong pid!");
80104835:	c7 04 24 f4 84 10 80 	movl   $0x801084f4,(%esp)
8010483c:	e8 3f bb ff ff       	call   80100380 <panic>
80104841:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104848:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010484f:	90                   	nop

80104850 <schedulerLock>:

void
schedulerLock(int password)
{
80104850:	55                   	push   %ebp
80104851:	89 e5                	mov    %esp,%ebp
80104853:	56                   	push   %esi
  if(password == PASSWORD){
80104854:	81 7d 08 10 ab 58 78 	cmpl   $0x7858ab10,0x8(%ebp)
{
8010485b:	53                   	push   %ebx
  if(password == PASSWORD){
8010485c:	75 75                	jne    801048d3 <schedulerLock+0x83>
  pushcli();
8010485e:	e8 ad 03 00 00       	call   80104c10 <pushcli>
  c = mycpu();
80104863:	e8 e8 f0 ff ff       	call   80103950 <mycpu>
  p = c->proc;
80104868:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010486e:	e8 ed 03 00 00       	call   80104c60 <popcli>
    if(myproc()->locked)
80104873:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
80104879:	85 c0                	test   %eax,%eax
8010487b:	74 0b                	je     80104888 <schedulerLock+0x38>
  }
  else{
    cprintf("SchedulerLock: invalid password, pid: %d, time quantum: %d, level: %d\n", myproc()->pid, myproc()->tq, myproc()->lev);
    exit();
  }
}
8010487d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104880:	5b                   	pop    %ebx
80104881:	5e                   	pop    %esi
80104882:	5d                   	pop    %ebp
80104883:	c3                   	ret    
80104884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  pushcli();
80104888:	e8 83 03 00 00       	call   80104c10 <pushcli>
  c = mycpu();
8010488d:	e8 be f0 ff ff       	call   80103950 <mycpu>
  p = c->proc;
80104892:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104898:	e8 c3 03 00 00       	call   80104c60 <popcli>
    acquire(&tickslock);
8010489d:	83 ec 0c             	sub    $0xc,%esp
    myproc()->locked = 1;
801048a0:	c7 83 88 00 00 00 01 	movl   $0x1,0x88(%ebx)
801048a7:	00 00 00 
    acquire(&tickslock);
801048aa:	68 e0 53 11 80       	push   $0x801153e0
801048af:	e8 ac 04 00 00       	call   80104d60 <acquire>
    release(&tickslock);
801048b4:	c7 45 08 e0 53 11 80 	movl   $0x801153e0,0x8(%ebp)
801048bb:	83 c4 10             	add    $0x10,%esp
    ticks = 0;
801048be:	c7 05 c0 53 11 80 00 	movl   $0x0,0x801153c0
801048c5:	00 00 00 
}
801048c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801048cb:	5b                   	pop    %ebx
801048cc:	5e                   	pop    %esi
801048cd:	5d                   	pop    %ebp
    release(&tickslock);
801048ce:	e9 2d 04 00 00       	jmp    80104d00 <release>
    cprintf("SchedulerLock: invalid password, pid: %d, time quantum: %d, level: %d\n", myproc()->pid, myproc()->tq, myproc()->lev);
801048d3:	e8 f8 f0 ff ff       	call   801039d0 <myproc>
801048d8:	8b 70 7c             	mov    0x7c(%eax),%esi
801048db:	e8 f0 f0 ff ff       	call   801039d0 <myproc>
801048e0:	8b 98 80 00 00 00    	mov    0x80(%eax),%ebx
801048e6:	e8 e5 f0 ff ff       	call   801039d0 <myproc>
801048eb:	56                   	push   %esi
801048ec:	53                   	push   %ebx
801048ed:	ff 70 10             	push   0x10(%eax)
801048f0:	68 60 85 10 80       	push   $0x80108560
801048f5:	e8 a6 bd ff ff       	call   801006a0 <cprintf>
    exit();
801048fa:	e8 e1 f7 ff ff       	call   801040e0 <exit>
801048ff:	90                   	nop

80104900 <schedulerUnlock>:

void
schedulerUnlock(int password)
{
80104900:	55                   	push   %ebp
80104901:	89 e5                	mov    %esp,%ebp
80104903:	56                   	push   %esi
  if(password == PASSWORD){
80104904:	81 7d 08 10 ab 58 78 	cmpl   $0x7858ab10,0x8(%ebp)
{
8010490b:	53                   	push   %ebx
  if(password == PASSWORD){
8010490c:	0f 85 ff 00 00 00    	jne    80104a11 <schedulerUnlock+0x111>
  pushcli();
80104912:	e8 f9 02 00 00       	call   80104c10 <pushcli>
  c = mycpu();
80104917:	e8 34 f0 ff ff       	call   80103950 <mycpu>
  p = c->proc;
8010491c:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104922:	e8 39 03 00 00       	call   80104c60 <popcli>
    if(!myproc()->locked) // 이미 unlock 되어 있는 경우 skip
80104927:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
8010492d:	85 c0                	test   %eax,%eax
8010492f:	75 0f                	jne    80104940 <schedulerUnlock+0x40>
    cprintf("SchedulerUnlock: invalid password, pid: %d, time quantum: %d, level: %d\n", myproc()->pid, myproc()->tq, myproc()->lev);
    myproc()->tq = 0;
    myproc()->locked = 0;
    exit();
  }
80104931:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104934:	5b                   	pop    %ebx
80104935:	5e                   	pop    %esi
80104936:	5d                   	pop    %ebp
80104937:	c3                   	ret    
80104938:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010493f:	90                   	nop
  pushcli();
80104940:	e8 cb 02 00 00       	call   80104c10 <pushcli>
  c = mycpu();
80104945:	e8 06 f0 ff ff       	call   80103950 <mycpu>
  p = c->proc;
8010494a:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104950:	e8 0b 03 00 00       	call   80104c60 <popcli>
    myproc()->lev = 0;
80104955:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
  pushcli();
8010495c:	e8 af 02 00 00       	call   80104c10 <pushcli>
  c = mycpu();
80104961:	e8 ea ef ff ff       	call   80103950 <mycpu>
  p = c->proc;
80104966:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010496c:	e8 ef 02 00 00       	call   80104c60 <popcli>
    myproc()->priority = 3;
80104971:	c7 83 84 00 00 00 03 	movl   $0x3,0x84(%ebx)
80104978:	00 00 00 
  pushcli();
8010497b:	e8 90 02 00 00       	call   80104c10 <pushcli>
  c = mycpu();
80104980:	e8 cb ef ff ff       	call   80103950 <mycpu>
  p = c->proc;
80104985:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010498b:	e8 d0 02 00 00       	call   80104c60 <popcli>
    if(top(&mlfq.l0) != myproc()) // l0에서 lock된 경우가 아닐 때만 l0에 넣어줌. unlock되고 나면 스케줄러에서 lev이 다르므로 skip하게 됨
80104990:	83 ec 0c             	sub    $0xc,%esp
    myproc()->tq = 0;
80104993:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
8010499a:	00 00 00 
    if(top(&mlfq.l0) != myproc()) // l0에서 lock된 경우가 아닐 때만 l0에 넣어줌. unlock되고 나면 스케줄러에서 lev이 다르므로 skip하게 됨
8010499d:	68 40 2d 11 80       	push   $0x80112d40
801049a2:	e8 d9 33 00 00       	call   80107d80 <top>
801049a7:	89 c3                	mov    %eax,%ebx
  pushcli();
801049a9:	e8 62 02 00 00       	call   80104c10 <pushcli>
  c = mycpu();
801049ae:	e8 9d ef ff ff       	call   80103950 <mycpu>
  p = c->proc;
801049b3:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
801049b9:	e8 a2 02 00 00       	call   80104c60 <popcli>
    if(top(&mlfq.l0) != myproc()) // l0에서 lock된 경우가 아닐 때만 l0에 넣어줌. unlock되고 나면 스케줄러에서 lev이 다르므로 skip하게 됨
801049be:	83 c4 10             	add    $0x10,%esp
801049c1:	39 f3                	cmp    %esi,%ebx
801049c3:	74 26                	je     801049eb <schedulerUnlock+0xeb>
  pushcli();
801049c5:	e8 46 02 00 00       	call   80104c10 <pushcli>
  c = mycpu();
801049ca:	e8 81 ef ff ff       	call   80103950 <mycpu>
  p = c->proc;
801049cf:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801049d5:	e8 86 02 00 00       	call   80104c60 <popcli>
      push(&mlfq.l0, myproc());
801049da:	83 ec 08             	sub    $0x8,%esp
801049dd:	53                   	push   %ebx
801049de:	68 40 2d 11 80       	push   $0x80112d40
801049e3:	e8 d8 33 00 00       	call   80107dc0 <push>
801049e8:	83 c4 10             	add    $0x10,%esp
  pushcli();
801049eb:	e8 20 02 00 00       	call   80104c10 <pushcli>
  c = mycpu();
801049f0:	e8 5b ef ff ff       	call   80103950 <mycpu>
  p = c->proc;
801049f5:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801049fb:	e8 60 02 00 00       	call   80104c60 <popcli>
    myproc()->locked = 0;
80104a00:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
80104a07:	00 00 00 
80104a0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a0d:	5b                   	pop    %ebx
80104a0e:	5e                   	pop    %esi
80104a0f:	5d                   	pop    %ebp
80104a10:	c3                   	ret    
    cprintf("SchedulerUnlock: invalid password, pid: %d, time quantum: %d, level: %d\n", myproc()->pid, myproc()->tq, myproc()->lev);
80104a11:	e8 ba ef ff ff       	call   801039d0 <myproc>
80104a16:	8b 70 7c             	mov    0x7c(%eax),%esi
80104a19:	e8 b2 ef ff ff       	call   801039d0 <myproc>
80104a1e:	8b 98 80 00 00 00    	mov    0x80(%eax),%ebx
80104a24:	e8 a7 ef ff ff       	call   801039d0 <myproc>
80104a29:	56                   	push   %esi
80104a2a:	53                   	push   %ebx
80104a2b:	ff 70 10             	push   0x10(%eax)
80104a2e:	68 a8 85 10 80       	push   $0x801085a8
80104a33:	e8 68 bc ff ff       	call   801006a0 <cprintf>
    myproc()->tq = 0;
80104a38:	e8 93 ef ff ff       	call   801039d0 <myproc>
80104a3d:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104a44:	00 00 00 
    myproc()->locked = 0;
80104a47:	e8 84 ef ff ff       	call   801039d0 <myproc>
80104a4c:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104a53:	00 00 00 
    exit();
80104a56:	e8 85 f6 ff ff       	call   801040e0 <exit>
80104a5b:	66 90                	xchg   %ax,%ax
80104a5d:	66 90                	xchg   %ax,%ax
80104a5f:	90                   	nop

80104a60 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a60:	55                   	push   %ebp
80104a61:	89 e5                	mov    %esp,%ebp
80104a63:	53                   	push   %ebx
80104a64:	83 ec 0c             	sub    $0xc,%esp
80104a67:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80104a6a:	68 0c 86 10 80       	push   $0x8010860c
80104a6f:	8d 43 04             	lea    0x4(%ebx),%eax
80104a72:	50                   	push   %eax
80104a73:	e8 18 01 00 00       	call   80104b90 <initlock>
  lk->name = name;
80104a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
80104a7b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
80104a81:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
80104a84:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
80104a8b:	89 43 38             	mov    %eax,0x38(%ebx)
}
80104a8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a91:	c9                   	leave  
80104a92:	c3                   	ret    
80104a93:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104aa0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104aa0:	55                   	push   %ebp
80104aa1:	89 e5                	mov    %esp,%ebp
80104aa3:	56                   	push   %esi
80104aa4:	53                   	push   %ebx
80104aa5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104aa8:	8d 73 04             	lea    0x4(%ebx),%esi
80104aab:	83 ec 0c             	sub    $0xc,%esp
80104aae:	56                   	push   %esi
80104aaf:	e8 ac 02 00 00       	call   80104d60 <acquire>
  while (lk->locked) {
80104ab4:	8b 13                	mov    (%ebx),%edx
80104ab6:	83 c4 10             	add    $0x10,%esp
80104ab9:	85 d2                	test   %edx,%edx
80104abb:	74 16                	je     80104ad3 <acquiresleep+0x33>
80104abd:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
80104ac0:	83 ec 08             	sub    $0x8,%esp
80104ac3:	56                   	push   %esi
80104ac4:	53                   	push   %ebx
80104ac5:	e8 e6 f8 ff ff       	call   801043b0 <sleep>
  while (lk->locked) {
80104aca:	8b 03                	mov    (%ebx),%eax
80104acc:	83 c4 10             	add    $0x10,%esp
80104acf:	85 c0                	test   %eax,%eax
80104ad1:	75 ed                	jne    80104ac0 <acquiresleep+0x20>
  }
  lk->locked = 1;
80104ad3:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104ad9:	e8 f2 ee ff ff       	call   801039d0 <myproc>
80104ade:	8b 40 10             	mov    0x10(%eax),%eax
80104ae1:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80104ae4:	89 75 08             	mov    %esi,0x8(%ebp)
}
80104ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104aea:	5b                   	pop    %ebx
80104aeb:	5e                   	pop    %esi
80104aec:	5d                   	pop    %ebp
  release(&lk->lk);
80104aed:	e9 0e 02 00 00       	jmp    80104d00 <release>
80104af2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104b00 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104b00:	55                   	push   %ebp
80104b01:	89 e5                	mov    %esp,%ebp
80104b03:	56                   	push   %esi
80104b04:	53                   	push   %ebx
80104b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104b08:	8d 73 04             	lea    0x4(%ebx),%esi
80104b0b:	83 ec 0c             	sub    $0xc,%esp
80104b0e:	56                   	push   %esi
80104b0f:	e8 4c 02 00 00       	call   80104d60 <acquire>
  lk->locked = 0;
80104b14:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80104b1a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104b21:	89 1c 24             	mov    %ebx,(%esp)
80104b24:	e8 47 f9 ff ff       	call   80104470 <wakeup>
  release(&lk->lk);
80104b29:	89 75 08             	mov    %esi,0x8(%ebp)
80104b2c:	83 c4 10             	add    $0x10,%esp
}
80104b2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b32:	5b                   	pop    %ebx
80104b33:	5e                   	pop    %esi
80104b34:	5d                   	pop    %ebp
  release(&lk->lk);
80104b35:	e9 c6 01 00 00       	jmp    80104d00 <release>
80104b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104b40 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	57                   	push   %edi
80104b44:	31 ff                	xor    %edi,%edi
80104b46:	56                   	push   %esi
80104b47:	53                   	push   %ebx
80104b48:	83 ec 18             	sub    $0x18,%esp
80104b4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80104b4e:	8d 73 04             	lea    0x4(%ebx),%esi
80104b51:	56                   	push   %esi
80104b52:	e8 09 02 00 00       	call   80104d60 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80104b57:	8b 03                	mov    (%ebx),%eax
80104b59:	83 c4 10             	add    $0x10,%esp
80104b5c:	85 c0                	test   %eax,%eax
80104b5e:	75 18                	jne    80104b78 <holdingsleep+0x38>
  release(&lk->lk);
80104b60:	83 ec 0c             	sub    $0xc,%esp
80104b63:	56                   	push   %esi
80104b64:	e8 97 01 00 00       	call   80104d00 <release>
  return r;
}
80104b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104b6c:	89 f8                	mov    %edi,%eax
80104b6e:	5b                   	pop    %ebx
80104b6f:	5e                   	pop    %esi
80104b70:	5f                   	pop    %edi
80104b71:	5d                   	pop    %ebp
80104b72:	c3                   	ret    
80104b73:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104b77:	90                   	nop
  r = lk->locked && (lk->pid == myproc()->pid);
80104b78:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80104b7b:	e8 50 ee ff ff       	call   801039d0 <myproc>
80104b80:	39 58 10             	cmp    %ebx,0x10(%eax)
80104b83:	0f 94 c0             	sete   %al
80104b86:	0f b6 c0             	movzbl %al,%eax
80104b89:	89 c7                	mov    %eax,%edi
80104b8b:	eb d3                	jmp    80104b60 <holdingsleep+0x20>
80104b8d:	66 90                	xchg   %ax,%ax
80104b8f:	90                   	nop

80104b90 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b90:	55                   	push   %ebp
80104b91:	89 e5                	mov    %esp,%ebp
80104b93:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104b96:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104b99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
80104b9f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104ba2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ba9:	5d                   	pop    %ebp
80104baa:	c3                   	ret    
80104bab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104baf:	90                   	nop

80104bb0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104bb0:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104bb1:	31 d2                	xor    %edx,%edx
{
80104bb3:	89 e5                	mov    %esp,%ebp
80104bb5:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104bb6:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
80104bbc:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
80104bbf:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bc0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104bc6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104bcc:	77 1a                	ja     80104be8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104bce:	8b 58 04             	mov    0x4(%eax),%ebx
80104bd1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104bd4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104bd7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104bd9:	83 fa 0a             	cmp    $0xa,%edx
80104bdc:	75 e2                	jne    80104bc0 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
80104bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104be1:	c9                   	leave  
80104be2:	c3                   	ret    
80104be3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104be7:	90                   	nop
  for(; i < 10; i++)
80104be8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104beb:	8d 51 28             	lea    0x28(%ecx),%edx
80104bee:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104bf0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104bf6:	83 c0 04             	add    $0x4,%eax
80104bf9:	39 d0                	cmp    %edx,%eax
80104bfb:	75 f3                	jne    80104bf0 <getcallerpcs+0x40>
}
80104bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c00:	c9                   	leave  
80104c01:	c3                   	ret    
80104c02:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104c10 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c10:	55                   	push   %ebp
80104c11:	89 e5                	mov    %esp,%ebp
80104c13:	53                   	push   %ebx
80104c14:	83 ec 04             	sub    $0x4,%esp
80104c17:	9c                   	pushf  
80104c18:	5b                   	pop    %ebx
  asm volatile("cli");
80104c19:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80104c1a:	e8 31 ed ff ff       	call   80103950 <mycpu>
80104c1f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c25:	85 c0                	test   %eax,%eax
80104c27:	74 17                	je     80104c40 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104c29:	e8 22 ed ff ff       	call   80103950 <mycpu>
80104c2e:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80104c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c38:	c9                   	leave  
80104c39:	c3                   	ret    
80104c3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    mycpu()->intena = eflags & FL_IF;
80104c40:	e8 0b ed ff ff       	call   80103950 <mycpu>
80104c45:	81 e3 00 02 00 00    	and    $0x200,%ebx
80104c4b:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80104c51:	eb d6                	jmp    80104c29 <pushcli+0x19>
80104c53:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104c60 <popcli>:

void
popcli(void)
{
80104c60:	55                   	push   %ebp
80104c61:	89 e5                	mov    %esp,%ebp
80104c63:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104c66:	9c                   	pushf  
80104c67:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104c68:	f6 c4 02             	test   $0x2,%ah
80104c6b:	75 35                	jne    80104ca2 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80104c6d:	e8 de ec ff ff       	call   80103950 <mycpu>
80104c72:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104c79:	78 34                	js     80104caf <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104c7b:	e8 d0 ec ff ff       	call   80103950 <mycpu>
80104c80:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c86:	85 d2                	test   %edx,%edx
80104c88:	74 06                	je     80104c90 <popcli+0x30>
    sti();
}
80104c8a:	c9                   	leave  
80104c8b:	c3                   	ret    
80104c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104c90:	e8 bb ec ff ff       	call   80103950 <mycpu>
80104c95:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104c9b:	85 c0                	test   %eax,%eax
80104c9d:	74 eb                	je     80104c8a <popcli+0x2a>
  asm volatile("sti");
80104c9f:	fb                   	sti    
}
80104ca0:	c9                   	leave  
80104ca1:	c3                   	ret    
    panic("popcli - interruptible");
80104ca2:	83 ec 0c             	sub    $0xc,%esp
80104ca5:	68 17 86 10 80       	push   $0x80108617
80104caa:	e8 d1 b6 ff ff       	call   80100380 <panic>
    panic("popcli");
80104caf:	83 ec 0c             	sub    $0xc,%esp
80104cb2:	68 2e 86 10 80       	push   $0x8010862e
80104cb7:	e8 c4 b6 ff ff       	call   80100380 <panic>
80104cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104cc0 <holding>:
{
80104cc0:	55                   	push   %ebp
80104cc1:	89 e5                	mov    %esp,%ebp
80104cc3:	56                   	push   %esi
80104cc4:	53                   	push   %ebx
80104cc5:	8b 75 08             	mov    0x8(%ebp),%esi
80104cc8:	31 db                	xor    %ebx,%ebx
  pushcli();
80104cca:	e8 41 ff ff ff       	call   80104c10 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104ccf:	8b 06                	mov    (%esi),%eax
80104cd1:	85 c0                	test   %eax,%eax
80104cd3:	75 0b                	jne    80104ce0 <holding+0x20>
  popcli();
80104cd5:	e8 86 ff ff ff       	call   80104c60 <popcli>
}
80104cda:	89 d8                	mov    %ebx,%eax
80104cdc:	5b                   	pop    %ebx
80104cdd:	5e                   	pop    %esi
80104cde:	5d                   	pop    %ebp
80104cdf:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80104ce0:	8b 5e 08             	mov    0x8(%esi),%ebx
80104ce3:	e8 68 ec ff ff       	call   80103950 <mycpu>
80104ce8:	39 c3                	cmp    %eax,%ebx
80104cea:	0f 94 c3             	sete   %bl
  popcli();
80104ced:	e8 6e ff ff ff       	call   80104c60 <popcli>
  r = lock->locked && lock->cpu == mycpu();
80104cf2:	0f b6 db             	movzbl %bl,%ebx
}
80104cf5:	89 d8                	mov    %ebx,%eax
80104cf7:	5b                   	pop    %ebx
80104cf8:	5e                   	pop    %esi
80104cf9:	5d                   	pop    %ebp
80104cfa:	c3                   	ret    
80104cfb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104cff:	90                   	nop

80104d00 <release>:
{
80104d00:	55                   	push   %ebp
80104d01:	89 e5                	mov    %esp,%ebp
80104d03:	56                   	push   %esi
80104d04:	53                   	push   %ebx
80104d05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80104d08:	e8 03 ff ff ff       	call   80104c10 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104d0d:	8b 03                	mov    (%ebx),%eax
80104d0f:	85 c0                	test   %eax,%eax
80104d11:	75 15                	jne    80104d28 <release+0x28>
  popcli();
80104d13:	e8 48 ff ff ff       	call   80104c60 <popcli>
    panic("release");
80104d18:	83 ec 0c             	sub    $0xc,%esp
80104d1b:	68 35 86 10 80       	push   $0x80108635
80104d20:	e8 5b b6 ff ff       	call   80100380 <panic>
80104d25:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104d28:	8b 73 08             	mov    0x8(%ebx),%esi
80104d2b:	e8 20 ec ff ff       	call   80103950 <mycpu>
80104d30:	39 c6                	cmp    %eax,%esi
80104d32:	75 df                	jne    80104d13 <release+0x13>
  popcli();
80104d34:	e8 27 ff ff ff       	call   80104c60 <popcli>
  lk->pcs[0] = 0;
80104d39:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104d40:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104d47:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104d4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104d52:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104d55:	5b                   	pop    %ebx
80104d56:	5e                   	pop    %esi
80104d57:	5d                   	pop    %ebp
  popcli();
80104d58:	e9 03 ff ff ff       	jmp    80104c60 <popcli>
80104d5d:	8d 76 00             	lea    0x0(%esi),%esi

80104d60 <acquire>:
{
80104d60:	55                   	push   %ebp
80104d61:	89 e5                	mov    %esp,%ebp
80104d63:	53                   	push   %ebx
80104d64:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104d67:	e8 a4 fe ff ff       	call   80104c10 <pushcli>
  if(holding(lk)) // 이미 lock 되어 있는지 확인
80104d6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80104d6f:	e8 9c fe ff ff       	call   80104c10 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104d74:	8b 03                	mov    (%ebx),%eax
80104d76:	85 c0                	test   %eax,%eax
80104d78:	75 7e                	jne    80104df8 <acquire+0x98>
  popcli();
80104d7a:	e8 e1 fe ff ff       	call   80104c60 <popcli>
  asm volatile("lock; xchgl %0, %1" :
80104d7f:	b9 01 00 00 00       	mov    $0x1,%ecx
80104d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(xchg(&lk->locked, 1) != 0)
80104d88:	8b 55 08             	mov    0x8(%ebp),%edx
80104d8b:	89 c8                	mov    %ecx,%eax
80104d8d:	f0 87 02             	lock xchg %eax,(%edx)
80104d90:	85 c0                	test   %eax,%eax
80104d92:	75 f4                	jne    80104d88 <acquire+0x28>
  __sync_synchronize();
80104d94:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104d99:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104d9c:	e8 af eb ff ff       	call   80103950 <mycpu>
  getcallerpcs(&lk, lk->pcs);
80104da1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ebp = (uint*)v - 2;
80104da4:	89 ea                	mov    %ebp,%edx
  lk->cpu = mycpu();
80104da6:	89 43 08             	mov    %eax,0x8(%ebx)
  for(i = 0; i < 10; i++){
80104da9:	31 c0                	xor    %eax,%eax
80104dab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104daf:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104db0:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104db6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104dbc:	77 1a                	ja     80104dd8 <acquire+0x78>
    pcs[i] = ebp[1];     // saved %eip
80104dbe:	8b 5a 04             	mov    0x4(%edx),%ebx
80104dc1:	89 5c 81 0c          	mov    %ebx,0xc(%ecx,%eax,4)
  for(i = 0; i < 10; i++){
80104dc5:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
80104dc8:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80104dca:	83 f8 0a             	cmp    $0xa,%eax
80104dcd:	75 e1                	jne    80104db0 <acquire+0x50>
}
80104dcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104dd2:	c9                   	leave  
80104dd3:	c3                   	ret    
80104dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
80104dd8:	8d 44 81 0c          	lea    0xc(%ecx,%eax,4),%eax
80104ddc:	8d 51 34             	lea    0x34(%ecx),%edx
80104ddf:	90                   	nop
    pcs[i] = 0;
80104de0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104de6:	83 c0 04             	add    $0x4,%eax
80104de9:	39 c2                	cmp    %eax,%edx
80104deb:	75 f3                	jne    80104de0 <acquire+0x80>
}
80104ded:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104df0:	c9                   	leave  
80104df1:	c3                   	ret    
80104df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104df8:	8b 5b 08             	mov    0x8(%ebx),%ebx
80104dfb:	e8 50 eb ff ff       	call   80103950 <mycpu>
80104e00:	39 c3                	cmp    %eax,%ebx
80104e02:	0f 85 72 ff ff ff    	jne    80104d7a <acquire+0x1a>
  popcli();
80104e08:	e8 53 fe ff ff       	call   80104c60 <popcli>
    panic("acquire");
80104e0d:	83 ec 0c             	sub    $0xc,%esp
80104e10:	68 3d 86 10 80       	push   $0x8010863d
80104e15:	e8 66 b5 ff ff       	call   80100380 <panic>
80104e1a:	66 90                	xchg   %ax,%ax
80104e1c:	66 90                	xchg   %ax,%ax
80104e1e:	66 90                	xchg   %ax,%ax

80104e20 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e20:	55                   	push   %ebp
80104e21:	89 e5                	mov    %esp,%ebp
80104e23:	57                   	push   %edi
80104e24:	8b 55 08             	mov    0x8(%ebp),%edx
80104e27:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104e2a:	53                   	push   %ebx
80104e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80104e2e:	89 d7                	mov    %edx,%edi
80104e30:	09 cf                	or     %ecx,%edi
80104e32:	83 e7 03             	and    $0x3,%edi
80104e35:	75 29                	jne    80104e60 <memset+0x40>
    c &= 0xFF;
80104e37:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e3a:	c1 e0 18             	shl    $0x18,%eax
80104e3d:	89 fb                	mov    %edi,%ebx
80104e3f:	c1 e9 02             	shr    $0x2,%ecx
80104e42:	c1 e3 10             	shl    $0x10,%ebx
80104e45:	09 d8                	or     %ebx,%eax
80104e47:	09 f8                	or     %edi,%eax
80104e49:	c1 e7 08             	shl    $0x8,%edi
80104e4c:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104e4e:	89 d7                	mov    %edx,%edi
80104e50:	fc                   	cld    
80104e51:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104e53:	5b                   	pop    %ebx
80104e54:	89 d0                	mov    %edx,%eax
80104e56:	5f                   	pop    %edi
80104e57:	5d                   	pop    %ebp
80104e58:	c3                   	ret    
80104e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("cld; rep stosb" :
80104e60:	89 d7                	mov    %edx,%edi
80104e62:	fc                   	cld    
80104e63:	f3 aa                	rep stos %al,%es:(%edi)
80104e65:	5b                   	pop    %ebx
80104e66:	89 d0                	mov    %edx,%eax
80104e68:	5f                   	pop    %edi
80104e69:	5d                   	pop    %ebp
80104e6a:	c3                   	ret    
80104e6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104e6f:	90                   	nop

80104e70 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e70:	55                   	push   %ebp
80104e71:	89 e5                	mov    %esp,%ebp
80104e73:	56                   	push   %esi
80104e74:	8b 75 10             	mov    0x10(%ebp),%esi
80104e77:	8b 55 08             	mov    0x8(%ebp),%edx
80104e7a:	53                   	push   %ebx
80104e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104e7e:	85 f6                	test   %esi,%esi
80104e80:	74 2e                	je     80104eb0 <memcmp+0x40>
80104e82:	01 c6                	add    %eax,%esi
80104e84:	eb 14                	jmp    80104e9a <memcmp+0x2a>
80104e86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e8d:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104e90:	83 c0 01             	add    $0x1,%eax
80104e93:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104e96:	39 f0                	cmp    %esi,%eax
80104e98:	74 16                	je     80104eb0 <memcmp+0x40>
    if(*s1 != *s2)
80104e9a:	0f b6 0a             	movzbl (%edx),%ecx
80104e9d:	0f b6 18             	movzbl (%eax),%ebx
80104ea0:	38 d9                	cmp    %bl,%cl
80104ea2:	74 ec                	je     80104e90 <memcmp+0x20>
      return *s1 - *s2;
80104ea4:	0f b6 c1             	movzbl %cl,%eax
80104ea7:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104ea9:	5b                   	pop    %ebx
80104eaa:	5e                   	pop    %esi
80104eab:	5d                   	pop    %ebp
80104eac:	c3                   	ret    
80104ead:	8d 76 00             	lea    0x0(%esi),%esi
80104eb0:	5b                   	pop    %ebx
  return 0;
80104eb1:	31 c0                	xor    %eax,%eax
}
80104eb3:	5e                   	pop    %esi
80104eb4:	5d                   	pop    %ebp
80104eb5:	c3                   	ret    
80104eb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ebd:	8d 76 00             	lea    0x0(%esi),%esi

80104ec0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ec0:	55                   	push   %ebp
80104ec1:	89 e5                	mov    %esp,%ebp
80104ec3:	57                   	push   %edi
80104ec4:	8b 55 08             	mov    0x8(%ebp),%edx
80104ec7:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104eca:	56                   	push   %esi
80104ecb:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104ece:	39 d6                	cmp    %edx,%esi
80104ed0:	73 26                	jae    80104ef8 <memmove+0x38>
80104ed2:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
80104ed5:	39 fa                	cmp    %edi,%edx
80104ed7:	73 1f                	jae    80104ef8 <memmove+0x38>
80104ed9:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
80104edc:	85 c9                	test   %ecx,%ecx
80104ede:	74 0c                	je     80104eec <memmove+0x2c>
      *--d = *--s;
80104ee0:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80104ee4:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80104ee7:	83 e8 01             	sub    $0x1,%eax
80104eea:	73 f4                	jae    80104ee0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104eec:	5e                   	pop    %esi
80104eed:	89 d0                	mov    %edx,%eax
80104eef:	5f                   	pop    %edi
80104ef0:	5d                   	pop    %ebp
80104ef1:	c3                   	ret    
80104ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(n-- > 0)
80104ef8:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
80104efb:	89 d7                	mov    %edx,%edi
80104efd:	85 c9                	test   %ecx,%ecx
80104eff:	74 eb                	je     80104eec <memmove+0x2c>
80104f01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80104f08:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80104f09:	39 c6                	cmp    %eax,%esi
80104f0b:	75 fb                	jne    80104f08 <memmove+0x48>
}
80104f0d:	5e                   	pop    %esi
80104f0e:	89 d0                	mov    %edx,%eax
80104f10:	5f                   	pop    %edi
80104f11:	5d                   	pop    %ebp
80104f12:	c3                   	ret    
80104f13:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104f20 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80104f20:	eb 9e                	jmp    80104ec0 <memmove>
80104f22:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104f30 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104f30:	55                   	push   %ebp
80104f31:	89 e5                	mov    %esp,%ebp
80104f33:	56                   	push   %esi
80104f34:	8b 75 10             	mov    0x10(%ebp),%esi
80104f37:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f3a:	53                   	push   %ebx
80104f3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(n > 0 && *p && *p == *q)
80104f3e:	85 f6                	test   %esi,%esi
80104f40:	74 2e                	je     80104f70 <strncmp+0x40>
80104f42:	01 d6                	add    %edx,%esi
80104f44:	eb 18                	jmp    80104f5e <strncmp+0x2e>
80104f46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f4d:	8d 76 00             	lea    0x0(%esi),%esi
80104f50:	38 d8                	cmp    %bl,%al
80104f52:	75 14                	jne    80104f68 <strncmp+0x38>
    n--, p++, q++;
80104f54:	83 c2 01             	add    $0x1,%edx
80104f57:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104f5a:	39 f2                	cmp    %esi,%edx
80104f5c:	74 12                	je     80104f70 <strncmp+0x40>
80104f5e:	0f b6 01             	movzbl (%ecx),%eax
80104f61:	0f b6 1a             	movzbl (%edx),%ebx
80104f64:	84 c0                	test   %al,%al
80104f66:	75 e8                	jne    80104f50 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104f68:	29 d8                	sub    %ebx,%eax
}
80104f6a:	5b                   	pop    %ebx
80104f6b:	5e                   	pop    %esi
80104f6c:	5d                   	pop    %ebp
80104f6d:	c3                   	ret    
80104f6e:	66 90                	xchg   %ax,%ax
80104f70:	5b                   	pop    %ebx
    return 0;
80104f71:	31 c0                	xor    %eax,%eax
}
80104f73:	5e                   	pop    %esi
80104f74:	5d                   	pop    %ebp
80104f75:	c3                   	ret    
80104f76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f7d:	8d 76 00             	lea    0x0(%esi),%esi

80104f80 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f80:	55                   	push   %ebp
80104f81:	89 e5                	mov    %esp,%ebp
80104f83:	57                   	push   %edi
80104f84:	56                   	push   %esi
80104f85:	8b 75 08             	mov    0x8(%ebp),%esi
80104f88:	53                   	push   %ebx
80104f89:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f8c:	89 f0                	mov    %esi,%eax
80104f8e:	eb 15                	jmp    80104fa5 <strncpy+0x25>
80104f90:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104f94:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104f97:	83 c0 01             	add    $0x1,%eax
80104f9a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
80104f9e:	88 50 ff             	mov    %dl,-0x1(%eax)
80104fa1:	84 d2                	test   %dl,%dl
80104fa3:	74 09                	je     80104fae <strncpy+0x2e>
80104fa5:	89 cb                	mov    %ecx,%ebx
80104fa7:	83 e9 01             	sub    $0x1,%ecx
80104faa:	85 db                	test   %ebx,%ebx
80104fac:	7f e2                	jg     80104f90 <strncpy+0x10>
    ;
  while(n-- > 0)
80104fae:	89 c2                	mov    %eax,%edx
80104fb0:	85 c9                	test   %ecx,%ecx
80104fb2:	7e 17                	jle    80104fcb <strncpy+0x4b>
80104fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104fb8:	83 c2 01             	add    $0x1,%edx
80104fbb:	89 c1                	mov    %eax,%ecx
80104fbd:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
  while(n-- > 0)
80104fc1:	29 d1                	sub    %edx,%ecx
80104fc3:	8d 4c 0b ff          	lea    -0x1(%ebx,%ecx,1),%ecx
80104fc7:	85 c9                	test   %ecx,%ecx
80104fc9:	7f ed                	jg     80104fb8 <strncpy+0x38>
  return os;
}
80104fcb:	5b                   	pop    %ebx
80104fcc:	89 f0                	mov    %esi,%eax
80104fce:	5e                   	pop    %esi
80104fcf:	5f                   	pop    %edi
80104fd0:	5d                   	pop    %ebp
80104fd1:	c3                   	ret    
80104fd2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104fe0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104fe0:	55                   	push   %ebp
80104fe1:	89 e5                	mov    %esp,%ebp
80104fe3:	56                   	push   %esi
80104fe4:	8b 55 10             	mov    0x10(%ebp),%edx
80104fe7:	8b 75 08             	mov    0x8(%ebp),%esi
80104fea:	53                   	push   %ebx
80104feb:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104fee:	85 d2                	test   %edx,%edx
80104ff0:	7e 25                	jle    80105017 <safestrcpy+0x37>
80104ff2:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104ff6:	89 f2                	mov    %esi,%edx
80104ff8:	eb 16                	jmp    80105010 <safestrcpy+0x30>
80104ffa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80105000:	0f b6 08             	movzbl (%eax),%ecx
80105003:	83 c0 01             	add    $0x1,%eax
80105006:	83 c2 01             	add    $0x1,%edx
80105009:	88 4a ff             	mov    %cl,-0x1(%edx)
8010500c:	84 c9                	test   %cl,%cl
8010500e:	74 04                	je     80105014 <safestrcpy+0x34>
80105010:	39 d8                	cmp    %ebx,%eax
80105012:	75 ec                	jne    80105000 <safestrcpy+0x20>
    ;
  *s = 0;
80105014:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80105017:	89 f0                	mov    %esi,%eax
80105019:	5b                   	pop    %ebx
8010501a:	5e                   	pop    %esi
8010501b:	5d                   	pop    %ebp
8010501c:	c3                   	ret    
8010501d:	8d 76 00             	lea    0x0(%esi),%esi

80105020 <strlen>:

int
strlen(const char *s)
{
80105020:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80105021:	31 c0                	xor    %eax,%eax
{
80105023:	89 e5                	mov    %esp,%ebp
80105025:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80105028:	80 3a 00             	cmpb   $0x0,(%edx)
8010502b:	74 0c                	je     80105039 <strlen+0x19>
8010502d:	8d 76 00             	lea    0x0(%esi),%esi
80105030:	83 c0 01             	add    $0x1,%eax
80105033:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80105037:	75 f7                	jne    80105030 <strlen+0x10>
    ;
  return n;
}
80105039:	5d                   	pop    %ebp
8010503a:	c3                   	ret    

8010503b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010503b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010503f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105043:	55                   	push   %ebp
  pushl %ebx
80105044:	53                   	push   %ebx
  pushl %esi
80105045:	56                   	push   %esi
  pushl %edi
80105046:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105047:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105049:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010504b:	5f                   	pop    %edi
  popl %esi
8010504c:	5e                   	pop    %esi
  popl %ebx
8010504d:	5b                   	pop    %ebx
  popl %ebp
8010504e:	5d                   	pop    %ebp
  ret
8010504f:	c3                   	ret    

80105050 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105050:	55                   	push   %ebp
80105051:	89 e5                	mov    %esp,%ebp
80105053:	53                   	push   %ebx
80105054:	83 ec 04             	sub    $0x4,%esp
80105057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
8010505a:	e8 71 e9 ff ff       	call   801039d0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010505f:	8b 00                	mov    (%eax),%eax
80105061:	39 d8                	cmp    %ebx,%eax
80105063:	76 1b                	jbe    80105080 <fetchint+0x30>
80105065:	8d 53 04             	lea    0x4(%ebx),%edx
80105068:	39 d0                	cmp    %edx,%eax
8010506a:	72 14                	jb     80105080 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
8010506c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010506f:	8b 13                	mov    (%ebx),%edx
80105071:	89 10                	mov    %edx,(%eax)
  return 0;
80105073:	31 c0                	xor    %eax,%eax
}
80105075:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105078:	c9                   	leave  
80105079:	c3                   	ret    
8010507a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105080:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105085:	eb ee                	jmp    80105075 <fetchint+0x25>
80105087:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010508e:	66 90                	xchg   %ax,%ax

80105090 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105090:	55                   	push   %ebp
80105091:	89 e5                	mov    %esp,%ebp
80105093:	53                   	push   %ebx
80105094:	83 ec 04             	sub    $0x4,%esp
80105097:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
8010509a:	e8 31 e9 ff ff       	call   801039d0 <myproc>

  if(addr >= curproc->sz)
8010509f:	39 18                	cmp    %ebx,(%eax)
801050a1:	76 2d                	jbe    801050d0 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
801050a3:	8b 55 0c             	mov    0xc(%ebp),%edx
801050a6:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
801050a8:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
801050aa:	39 d3                	cmp    %edx,%ebx
801050ac:	73 22                	jae    801050d0 <fetchstr+0x40>
801050ae:	89 d8                	mov    %ebx,%eax
801050b0:	eb 0d                	jmp    801050bf <fetchstr+0x2f>
801050b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801050b8:	83 c0 01             	add    $0x1,%eax
801050bb:	39 c2                	cmp    %eax,%edx
801050bd:	76 11                	jbe    801050d0 <fetchstr+0x40>
    if(*s == 0)
801050bf:	80 38 00             	cmpb   $0x0,(%eax)
801050c2:	75 f4                	jne    801050b8 <fetchstr+0x28>
      return s - *pp;
801050c4:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
801050c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050c9:	c9                   	leave  
801050ca:	c3                   	ret    
801050cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801050cf:	90                   	nop
801050d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
801050d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050d8:	c9                   	leave  
801050d9:	c3                   	ret    
801050da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801050e0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801050e0:	55                   	push   %ebp
801050e1:	89 e5                	mov    %esp,%ebp
801050e3:	56                   	push   %esi
801050e4:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801050e5:	e8 e6 e8 ff ff       	call   801039d0 <myproc>
801050ea:	8b 55 08             	mov    0x8(%ebp),%edx
801050ed:	8b 40 18             	mov    0x18(%eax),%eax
801050f0:	8b 40 44             	mov    0x44(%eax),%eax
801050f3:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
801050f6:	e8 d5 e8 ff ff       	call   801039d0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801050fb:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
801050fe:	8b 00                	mov    (%eax),%eax
80105100:	39 c6                	cmp    %eax,%esi
80105102:	73 1c                	jae    80105120 <argint+0x40>
80105104:	8d 53 08             	lea    0x8(%ebx),%edx
80105107:	39 d0                	cmp    %edx,%eax
80105109:	72 15                	jb     80105120 <argint+0x40>
  *ip = *(int*)(addr);
8010510b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510e:	8b 53 04             	mov    0x4(%ebx),%edx
80105111:	89 10                	mov    %edx,(%eax)
  return 0;
80105113:	31 c0                	xor    %eax,%eax
}
80105115:	5b                   	pop    %ebx
80105116:	5e                   	pop    %esi
80105117:	5d                   	pop    %ebp
80105118:	c3                   	ret    
80105119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105125:	eb ee                	jmp    80105115 <argint+0x35>
80105127:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010512e:	66 90                	xchg   %ax,%ax

80105130 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105130:	55                   	push   %ebp
80105131:	89 e5                	mov    %esp,%ebp
80105133:	57                   	push   %edi
80105134:	56                   	push   %esi
80105135:	53                   	push   %ebx
80105136:	83 ec 0c             	sub    $0xc,%esp
  int i;
  struct proc *curproc = myproc();
80105139:	e8 92 e8 ff ff       	call   801039d0 <myproc>
8010513e:	89 c6                	mov    %eax,%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105140:	e8 8b e8 ff ff       	call   801039d0 <myproc>
80105145:	8b 55 08             	mov    0x8(%ebp),%edx
80105148:	8b 40 18             	mov    0x18(%eax),%eax
8010514b:	8b 40 44             	mov    0x44(%eax),%eax
8010514e:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80105151:	e8 7a e8 ff ff       	call   801039d0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105156:	8d 7b 04             	lea    0x4(%ebx),%edi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105159:	8b 00                	mov    (%eax),%eax
8010515b:	39 c7                	cmp    %eax,%edi
8010515d:	73 31                	jae    80105190 <argptr+0x60>
8010515f:	8d 4b 08             	lea    0x8(%ebx),%ecx
80105162:	39 c8                	cmp    %ecx,%eax
80105164:	72 2a                	jb     80105190 <argptr+0x60>
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105166:	8b 55 10             	mov    0x10(%ebp),%edx
  *ip = *(int*)(addr);
80105169:	8b 43 04             	mov    0x4(%ebx),%eax
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010516c:	85 d2                	test   %edx,%edx
8010516e:	78 20                	js     80105190 <argptr+0x60>
80105170:	8b 16                	mov    (%esi),%edx
80105172:	39 c2                	cmp    %eax,%edx
80105174:	76 1a                	jbe    80105190 <argptr+0x60>
80105176:	8b 5d 10             	mov    0x10(%ebp),%ebx
80105179:	01 c3                	add    %eax,%ebx
8010517b:	39 da                	cmp    %ebx,%edx
8010517d:	72 11                	jb     80105190 <argptr+0x60>
    return -1;
  *pp = (char*)i;
8010517f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105182:	89 02                	mov    %eax,(%edx)
  return 0;
80105184:	31 c0                	xor    %eax,%eax
}
80105186:	83 c4 0c             	add    $0xc,%esp
80105189:	5b                   	pop    %ebx
8010518a:	5e                   	pop    %esi
8010518b:	5f                   	pop    %edi
8010518c:	5d                   	pop    %ebp
8010518d:	c3                   	ret    
8010518e:	66 90                	xchg   %ax,%ax
    return -1;
80105190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105195:	eb ef                	jmp    80105186 <argptr+0x56>
80105197:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010519e:	66 90                	xchg   %ax,%ax

801051a0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801051a0:	55                   	push   %ebp
801051a1:	89 e5                	mov    %esp,%ebp
801051a3:	56                   	push   %esi
801051a4:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801051a5:	e8 26 e8 ff ff       	call   801039d0 <myproc>
801051aa:	8b 55 08             	mov    0x8(%ebp),%edx
801051ad:	8b 40 18             	mov    0x18(%eax),%eax
801051b0:	8b 40 44             	mov    0x44(%eax),%eax
801051b3:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
801051b6:	e8 15 e8 ff ff       	call   801039d0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801051bb:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
801051be:	8b 00                	mov    (%eax),%eax
801051c0:	39 c6                	cmp    %eax,%esi
801051c2:	73 44                	jae    80105208 <argstr+0x68>
801051c4:	8d 53 08             	lea    0x8(%ebx),%edx
801051c7:	39 d0                	cmp    %edx,%eax
801051c9:	72 3d                	jb     80105208 <argstr+0x68>
  *ip = *(int*)(addr);
801051cb:	8b 5b 04             	mov    0x4(%ebx),%ebx
  struct proc *curproc = myproc();
801051ce:	e8 fd e7 ff ff       	call   801039d0 <myproc>
  if(addr >= curproc->sz)
801051d3:	3b 18                	cmp    (%eax),%ebx
801051d5:	73 31                	jae    80105208 <argstr+0x68>
  *pp = (char*)addr;
801051d7:	8b 55 0c             	mov    0xc(%ebp),%edx
801051da:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
801051dc:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
801051de:	39 d3                	cmp    %edx,%ebx
801051e0:	73 26                	jae    80105208 <argstr+0x68>
801051e2:	89 d8                	mov    %ebx,%eax
801051e4:	eb 11                	jmp    801051f7 <argstr+0x57>
801051e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801051ed:	8d 76 00             	lea    0x0(%esi),%esi
801051f0:	83 c0 01             	add    $0x1,%eax
801051f3:	39 c2                	cmp    %eax,%edx
801051f5:	76 11                	jbe    80105208 <argstr+0x68>
    if(*s == 0)
801051f7:	80 38 00             	cmpb   $0x0,(%eax)
801051fa:	75 f4                	jne    801051f0 <argstr+0x50>
      return s - *pp;
801051fc:	29 d8                	sub    %ebx,%eax
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}
801051fe:	5b                   	pop    %ebx
801051ff:	5e                   	pop    %esi
80105200:	5d                   	pop    %ebp
80105201:	c3                   	ret    
80105202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105208:	5b                   	pop    %ebx
    return -1;
80105209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010520e:	5e                   	pop    %esi
8010520f:	5d                   	pop    %ebp
80105210:	c3                   	ret    
80105211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105218:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010521f:	90                   	nop

80105220 <syscall>:
[SYS_schedulerUnlock] sys_schedulerUnlock,
};

void
syscall(void)
{
80105220:	55                   	push   %ebp
80105221:	89 e5                	mov    %esp,%ebp
80105223:	53                   	push   %ebx
80105224:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80105227:	e8 a4 e7 ff ff       	call   801039d0 <myproc>
8010522c:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010522e:	8b 40 18             	mov    0x18(%eax),%eax
80105231:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105234:	8d 50 ff             	lea    -0x1(%eax),%edx
80105237:	83 fa 1a             	cmp    $0x1a,%edx
8010523a:	77 24                	ja     80105260 <syscall+0x40>
8010523c:	8b 14 85 80 86 10 80 	mov    -0x7fef7980(,%eax,4),%edx
80105243:	85 d2                	test   %edx,%edx
80105245:	74 19                	je     80105260 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80105247:	ff d2                	call   *%edx
80105249:	89 c2                	mov    %eax,%edx
8010524b:	8b 43 18             	mov    0x18(%ebx),%eax
8010524e:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80105251:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105254:	c9                   	leave  
80105255:	c3                   	ret    
80105256:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010525d:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80105260:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80105261:	8d 43 6c             	lea    0x6c(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80105264:	50                   	push   %eax
80105265:	ff 73 10             	push   0x10(%ebx)
80105268:	68 45 86 10 80       	push   $0x80108645
8010526d:	e8 2e b4 ff ff       	call   801006a0 <cprintf>
    curproc->tf->eax = -1;
80105272:	8b 43 18             	mov    0x18(%ebx),%eax
80105275:	83 c4 10             	add    $0x10,%esp
80105278:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
8010527f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105282:	c9                   	leave  
80105283:	c3                   	ret    
80105284:	66 90                	xchg   %ax,%ax
80105286:	66 90                	xchg   %ax,%ax
80105288:	66 90                	xchg   %ax,%ax
8010528a:	66 90                	xchg   %ax,%ax
8010528c:	66 90                	xchg   %ax,%ax
8010528e:	66 90                	xchg   %ax,%ax

80105290 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80105290:	55                   	push   %ebp
80105291:	89 e5                	mov    %esp,%ebp
80105293:	57                   	push   %edi
80105294:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105295:	8d 7d da             	lea    -0x26(%ebp),%edi
{
80105298:	53                   	push   %ebx
80105299:	83 ec 34             	sub    $0x34,%esp
8010529c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010529f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
801052a2:	57                   	push   %edi
801052a3:	50                   	push   %eax
{
801052a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801052a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
801052aa:	e8 11 ce ff ff       	call   801020c0 <nameiparent>
801052af:	83 c4 10             	add    $0x10,%esp
801052b2:	85 c0                	test   %eax,%eax
801052b4:	0f 84 46 01 00 00    	je     80105400 <create+0x170>
    return 0;
  ilock(dp);
801052ba:	83 ec 0c             	sub    $0xc,%esp
801052bd:	89 c3                	mov    %eax,%ebx
801052bf:	50                   	push   %eax
801052c0:	e8 bb c4 ff ff       	call   80101780 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801052c5:	83 c4 0c             	add    $0xc,%esp
801052c8:	6a 00                	push   $0x0
801052ca:	57                   	push   %edi
801052cb:	53                   	push   %ebx
801052cc:	e8 0f ca ff ff       	call   80101ce0 <dirlookup>
801052d1:	83 c4 10             	add    $0x10,%esp
801052d4:	89 c6                	mov    %eax,%esi
801052d6:	85 c0                	test   %eax,%eax
801052d8:	74 56                	je     80105330 <create+0xa0>
    iunlockput(dp);
801052da:	83 ec 0c             	sub    $0xc,%esp
801052dd:	53                   	push   %ebx
801052de:	e8 2d c7 ff ff       	call   80101a10 <iunlockput>
    ilock(ip);
801052e3:	89 34 24             	mov    %esi,(%esp)
801052e6:	e8 95 c4 ff ff       	call   80101780 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801052eb:	83 c4 10             	add    $0x10,%esp
801052ee:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801052f3:	75 1b                	jne    80105310 <create+0x80>
801052f5:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
801052fa:	75 14                	jne    80105310 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801052fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801052ff:	89 f0                	mov    %esi,%eax
80105301:	5b                   	pop    %ebx
80105302:	5e                   	pop    %esi
80105303:	5f                   	pop    %edi
80105304:	5d                   	pop    %ebp
80105305:	c3                   	ret    
80105306:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010530d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105310:	83 ec 0c             	sub    $0xc,%esp
80105313:	56                   	push   %esi
    return 0;
80105314:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80105316:	e8 f5 c6 ff ff       	call   80101a10 <iunlockput>
    return 0;
8010531b:	83 c4 10             	add    $0x10,%esp
}
8010531e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105321:	89 f0                	mov    %esi,%eax
80105323:	5b                   	pop    %ebx
80105324:	5e                   	pop    %esi
80105325:	5f                   	pop    %edi
80105326:	5d                   	pop    %ebp
80105327:	c3                   	ret    
80105328:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010532f:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80105330:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80105334:	83 ec 08             	sub    $0x8,%esp
80105337:	50                   	push   %eax
80105338:	ff 33                	push   (%ebx)
8010533a:	e8 d1 c2 ff ff       	call   80101610 <ialloc>
8010533f:	83 c4 10             	add    $0x10,%esp
80105342:	89 c6                	mov    %eax,%esi
80105344:	85 c0                	test   %eax,%eax
80105346:	0f 84 cd 00 00 00    	je     80105419 <create+0x189>
  ilock(ip);
8010534c:	83 ec 0c             	sub    $0xc,%esp
8010534f:	50                   	push   %eax
80105350:	e8 2b c4 ff ff       	call   80101780 <ilock>
  ip->major = major;
80105355:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80105359:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
8010535d:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
80105361:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80105365:	b8 01 00 00 00       	mov    $0x1,%eax
8010536a:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
8010536e:	89 34 24             	mov    %esi,(%esp)
80105371:	e8 5a c3 ff ff       	call   801016d0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80105376:	83 c4 10             	add    $0x10,%esp
80105379:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010537e:	74 30                	je     801053b0 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80105380:	83 ec 04             	sub    $0x4,%esp
80105383:	ff 76 04             	push   0x4(%esi)
80105386:	57                   	push   %edi
80105387:	53                   	push   %ebx
80105388:	e8 53 cc ff ff       	call   80101fe0 <dirlink>
8010538d:	83 c4 10             	add    $0x10,%esp
80105390:	85 c0                	test   %eax,%eax
80105392:	78 78                	js     8010540c <create+0x17c>
  iunlockput(dp);
80105394:	83 ec 0c             	sub    $0xc,%esp
80105397:	53                   	push   %ebx
80105398:	e8 73 c6 ff ff       	call   80101a10 <iunlockput>
  return ip;
8010539d:	83 c4 10             	add    $0x10,%esp
}
801053a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053a3:	89 f0                	mov    %esi,%eax
801053a5:	5b                   	pop    %ebx
801053a6:	5e                   	pop    %esi
801053a7:	5f                   	pop    %edi
801053a8:	5d                   	pop    %ebp
801053a9:	c3                   	ret    
801053aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
801053b0:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
801053b3:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
801053b8:	53                   	push   %ebx
801053b9:	e8 12 c3 ff ff       	call   801016d0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801053be:	83 c4 0c             	add    $0xc,%esp
801053c1:	ff 76 04             	push   0x4(%esi)
801053c4:	68 0c 87 10 80       	push   $0x8010870c
801053c9:	56                   	push   %esi
801053ca:	e8 11 cc ff ff       	call   80101fe0 <dirlink>
801053cf:	83 c4 10             	add    $0x10,%esp
801053d2:	85 c0                	test   %eax,%eax
801053d4:	78 18                	js     801053ee <create+0x15e>
801053d6:	83 ec 04             	sub    $0x4,%esp
801053d9:	ff 73 04             	push   0x4(%ebx)
801053dc:	68 0b 87 10 80       	push   $0x8010870b
801053e1:	56                   	push   %esi
801053e2:	e8 f9 cb ff ff       	call   80101fe0 <dirlink>
801053e7:	83 c4 10             	add    $0x10,%esp
801053ea:	85 c0                	test   %eax,%eax
801053ec:	79 92                	jns    80105380 <create+0xf0>
      panic("create dots");
801053ee:	83 ec 0c             	sub    $0xc,%esp
801053f1:	68 ff 86 10 80       	push   $0x801086ff
801053f6:	e8 85 af ff ff       	call   80100380 <panic>
801053fb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801053ff:	90                   	nop
}
80105400:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80105403:	31 f6                	xor    %esi,%esi
}
80105405:	5b                   	pop    %ebx
80105406:	89 f0                	mov    %esi,%eax
80105408:	5e                   	pop    %esi
80105409:	5f                   	pop    %edi
8010540a:	5d                   	pop    %ebp
8010540b:	c3                   	ret    
    panic("create: dirlink");
8010540c:	83 ec 0c             	sub    $0xc,%esp
8010540f:	68 0e 87 10 80       	push   $0x8010870e
80105414:	e8 67 af ff ff       	call   80100380 <panic>
    panic("create: ialloc");
80105419:	83 ec 0c             	sub    $0xc,%esp
8010541c:	68 f0 86 10 80       	push   $0x801086f0
80105421:	e8 5a af ff ff       	call   80100380 <panic>
80105426:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010542d:	8d 76 00             	lea    0x0(%esi),%esi

80105430 <sys_dup>:
{
80105430:	55                   	push   %ebp
80105431:	89 e5                	mov    %esp,%ebp
80105433:	56                   	push   %esi
80105434:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105435:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105438:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010543b:	50                   	push   %eax
8010543c:	6a 00                	push   $0x0
8010543e:	e8 9d fc ff ff       	call   801050e0 <argint>
80105443:	83 c4 10             	add    $0x10,%esp
80105446:	85 c0                	test   %eax,%eax
80105448:	78 36                	js     80105480 <sys_dup+0x50>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010544a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010544e:	77 30                	ja     80105480 <sys_dup+0x50>
80105450:	e8 7b e5 ff ff       	call   801039d0 <myproc>
80105455:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105458:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010545c:	85 f6                	test   %esi,%esi
8010545e:	74 20                	je     80105480 <sys_dup+0x50>
  struct proc *curproc = myproc();
80105460:	e8 6b e5 ff ff       	call   801039d0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105465:	31 db                	xor    %ebx,%ebx
80105467:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010546e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105470:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80105474:	85 d2                	test   %edx,%edx
80105476:	74 18                	je     80105490 <sys_dup+0x60>
  for(fd = 0; fd < NOFILE; fd++){
80105478:	83 c3 01             	add    $0x1,%ebx
8010547b:	83 fb 10             	cmp    $0x10,%ebx
8010547e:	75 f0                	jne    80105470 <sys_dup+0x40>
}
80105480:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80105483:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80105488:	89 d8                	mov    %ebx,%eax
8010548a:	5b                   	pop    %ebx
8010548b:	5e                   	pop    %esi
8010548c:	5d                   	pop    %ebp
8010548d:	c3                   	ret    
8010548e:	66 90                	xchg   %ax,%ax
  filedup(f);
80105490:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
80105493:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)
  filedup(f);
80105497:	56                   	push   %esi
80105498:	e8 03 ba ff ff       	call   80100ea0 <filedup>
  return fd;
8010549d:	83 c4 10             	add    $0x10,%esp
}
801054a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801054a3:	89 d8                	mov    %ebx,%eax
801054a5:	5b                   	pop    %ebx
801054a6:	5e                   	pop    %esi
801054a7:	5d                   	pop    %ebp
801054a8:	c3                   	ret    
801054a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801054b0 <sys_read>:
{
801054b0:	55                   	push   %ebp
801054b1:	89 e5                	mov    %esp,%ebp
801054b3:	56                   	push   %esi
801054b4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801054b5:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
801054b8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801054bb:	53                   	push   %ebx
801054bc:	6a 00                	push   $0x0
801054be:	e8 1d fc ff ff       	call   801050e0 <argint>
801054c3:	83 c4 10             	add    $0x10,%esp
801054c6:	85 c0                	test   %eax,%eax
801054c8:	78 5e                	js     80105528 <sys_read+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801054ca:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801054ce:	77 58                	ja     80105528 <sys_read+0x78>
801054d0:	e8 fb e4 ff ff       	call   801039d0 <myproc>
801054d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054d8:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
801054dc:	85 f6                	test   %esi,%esi
801054de:	74 48                	je     80105528 <sys_read+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801054e0:	83 ec 08             	sub    $0x8,%esp
801054e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054e6:	50                   	push   %eax
801054e7:	6a 02                	push   $0x2
801054e9:	e8 f2 fb ff ff       	call   801050e0 <argint>
801054ee:	83 c4 10             	add    $0x10,%esp
801054f1:	85 c0                	test   %eax,%eax
801054f3:	78 33                	js     80105528 <sys_read+0x78>
801054f5:	83 ec 04             	sub    $0x4,%esp
801054f8:	ff 75 f0             	push   -0x10(%ebp)
801054fb:	53                   	push   %ebx
801054fc:	6a 01                	push   $0x1
801054fe:	e8 2d fc ff ff       	call   80105130 <argptr>
80105503:	83 c4 10             	add    $0x10,%esp
80105506:	85 c0                	test   %eax,%eax
80105508:	78 1e                	js     80105528 <sys_read+0x78>
  return fileread(f, p, n);
8010550a:	83 ec 04             	sub    $0x4,%esp
8010550d:	ff 75 f0             	push   -0x10(%ebp)
80105510:	ff 75 f4             	push   -0xc(%ebp)
80105513:	56                   	push   %esi
80105514:	e8 07 bb ff ff       	call   80101020 <fileread>
80105519:	83 c4 10             	add    $0x10,%esp
}
8010551c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010551f:	5b                   	pop    %ebx
80105520:	5e                   	pop    %esi
80105521:	5d                   	pop    %ebp
80105522:	c3                   	ret    
80105523:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105527:	90                   	nop
    return -1;
80105528:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010552d:	eb ed                	jmp    8010551c <sys_read+0x6c>
8010552f:	90                   	nop

80105530 <sys_write>:
{
80105530:	55                   	push   %ebp
80105531:	89 e5                	mov    %esp,%ebp
80105533:	56                   	push   %esi
80105534:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105535:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105538:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010553b:	53                   	push   %ebx
8010553c:	6a 00                	push   $0x0
8010553e:	e8 9d fb ff ff       	call   801050e0 <argint>
80105543:	83 c4 10             	add    $0x10,%esp
80105546:	85 c0                	test   %eax,%eax
80105548:	78 5e                	js     801055a8 <sys_write+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010554a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010554e:	77 58                	ja     801055a8 <sys_write+0x78>
80105550:	e8 7b e4 ff ff       	call   801039d0 <myproc>
80105555:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105558:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010555c:	85 f6                	test   %esi,%esi
8010555e:	74 48                	je     801055a8 <sys_write+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105560:	83 ec 08             	sub    $0x8,%esp
80105563:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105566:	50                   	push   %eax
80105567:	6a 02                	push   $0x2
80105569:	e8 72 fb ff ff       	call   801050e0 <argint>
8010556e:	83 c4 10             	add    $0x10,%esp
80105571:	85 c0                	test   %eax,%eax
80105573:	78 33                	js     801055a8 <sys_write+0x78>
80105575:	83 ec 04             	sub    $0x4,%esp
80105578:	ff 75 f0             	push   -0x10(%ebp)
8010557b:	53                   	push   %ebx
8010557c:	6a 01                	push   $0x1
8010557e:	e8 ad fb ff ff       	call   80105130 <argptr>
80105583:	83 c4 10             	add    $0x10,%esp
80105586:	85 c0                	test   %eax,%eax
80105588:	78 1e                	js     801055a8 <sys_write+0x78>
  return filewrite(f, p, n);
8010558a:	83 ec 04             	sub    $0x4,%esp
8010558d:	ff 75 f0             	push   -0x10(%ebp)
80105590:	ff 75 f4             	push   -0xc(%ebp)
80105593:	56                   	push   %esi
80105594:	e8 17 bb ff ff       	call   801010b0 <filewrite>
80105599:	83 c4 10             	add    $0x10,%esp
}
8010559c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010559f:	5b                   	pop    %ebx
801055a0:	5e                   	pop    %esi
801055a1:	5d                   	pop    %ebp
801055a2:	c3                   	ret    
801055a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801055a7:	90                   	nop
    return -1;
801055a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ad:	eb ed                	jmp    8010559c <sys_write+0x6c>
801055af:	90                   	nop

801055b0 <sys_close>:
{
801055b0:	55                   	push   %ebp
801055b1:	89 e5                	mov    %esp,%ebp
801055b3:	56                   	push   %esi
801055b4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801055b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
801055b8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801055bb:	50                   	push   %eax
801055bc:	6a 00                	push   $0x0
801055be:	e8 1d fb ff ff       	call   801050e0 <argint>
801055c3:	83 c4 10             	add    $0x10,%esp
801055c6:	85 c0                	test   %eax,%eax
801055c8:	78 3e                	js     80105608 <sys_close+0x58>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801055ca:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801055ce:	77 38                	ja     80105608 <sys_close+0x58>
801055d0:	e8 fb e3 ff ff       	call   801039d0 <myproc>
801055d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055d8:	8d 5a 08             	lea    0x8(%edx),%ebx
801055db:	8b 74 98 08          	mov    0x8(%eax,%ebx,4),%esi
801055df:	85 f6                	test   %esi,%esi
801055e1:	74 25                	je     80105608 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
801055e3:	e8 e8 e3 ff ff       	call   801039d0 <myproc>
  fileclose(f);
801055e8:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
801055eb:	c7 44 98 08 00 00 00 	movl   $0x0,0x8(%eax,%ebx,4)
801055f2:	00 
  fileclose(f);
801055f3:	56                   	push   %esi
801055f4:	e8 f7 b8 ff ff       	call   80100ef0 <fileclose>
  return 0;
801055f9:	83 c4 10             	add    $0x10,%esp
801055fc:	31 c0                	xor    %eax,%eax
}
801055fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105601:	5b                   	pop    %ebx
80105602:	5e                   	pop    %esi
80105603:	5d                   	pop    %ebp
80105604:	c3                   	ret    
80105605:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105608:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010560d:	eb ef                	jmp    801055fe <sys_close+0x4e>
8010560f:	90                   	nop

80105610 <sys_fstat>:
{
80105610:	55                   	push   %ebp
80105611:	89 e5                	mov    %esp,%ebp
80105613:	56                   	push   %esi
80105614:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105615:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105618:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010561b:	53                   	push   %ebx
8010561c:	6a 00                	push   $0x0
8010561e:	e8 bd fa ff ff       	call   801050e0 <argint>
80105623:	83 c4 10             	add    $0x10,%esp
80105626:	85 c0                	test   %eax,%eax
80105628:	78 46                	js     80105670 <sys_fstat+0x60>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010562a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010562e:	77 40                	ja     80105670 <sys_fstat+0x60>
80105630:	e8 9b e3 ff ff       	call   801039d0 <myproc>
80105635:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105638:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010563c:	85 f6                	test   %esi,%esi
8010563e:	74 30                	je     80105670 <sys_fstat+0x60>
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105640:	83 ec 04             	sub    $0x4,%esp
80105643:	6a 14                	push   $0x14
80105645:	53                   	push   %ebx
80105646:	6a 01                	push   $0x1
80105648:	e8 e3 fa ff ff       	call   80105130 <argptr>
8010564d:	83 c4 10             	add    $0x10,%esp
80105650:	85 c0                	test   %eax,%eax
80105652:	78 1c                	js     80105670 <sys_fstat+0x60>
  return filestat(f, st);
80105654:	83 ec 08             	sub    $0x8,%esp
80105657:	ff 75 f4             	push   -0xc(%ebp)
8010565a:	56                   	push   %esi
8010565b:	e8 70 b9 ff ff       	call   80100fd0 <filestat>
80105660:	83 c4 10             	add    $0x10,%esp
}
80105663:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105666:	5b                   	pop    %ebx
80105667:	5e                   	pop    %esi
80105668:	5d                   	pop    %ebp
80105669:	c3                   	ret    
8010566a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105670:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105675:	eb ec                	jmp    80105663 <sys_fstat+0x53>
80105677:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010567e:	66 90                	xchg   %ax,%ax

80105680 <sys_link>:
{
80105680:	55                   	push   %ebp
80105681:	89 e5                	mov    %esp,%ebp
80105683:	57                   	push   %edi
80105684:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105685:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105688:	53                   	push   %ebx
80105689:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010568c:	50                   	push   %eax
8010568d:	6a 00                	push   $0x0
8010568f:	e8 0c fb ff ff       	call   801051a0 <argstr>
80105694:	83 c4 10             	add    $0x10,%esp
80105697:	85 c0                	test   %eax,%eax
80105699:	0f 88 fb 00 00 00    	js     8010579a <sys_link+0x11a>
8010569f:	83 ec 08             	sub    $0x8,%esp
801056a2:	8d 45 d0             	lea    -0x30(%ebp),%eax
801056a5:	50                   	push   %eax
801056a6:	6a 01                	push   $0x1
801056a8:	e8 f3 fa ff ff       	call   801051a0 <argstr>
801056ad:	83 c4 10             	add    $0x10,%esp
801056b0:	85 c0                	test   %eax,%eax
801056b2:	0f 88 e2 00 00 00    	js     8010579a <sys_link+0x11a>
  begin_op();
801056b8:	e8 a3 d6 ff ff       	call   80102d60 <begin_op>
  if((ip = namei(old)) == 0){
801056bd:	83 ec 0c             	sub    $0xc,%esp
801056c0:	ff 75 d4             	push   -0x2c(%ebp)
801056c3:	e8 d8 c9 ff ff       	call   801020a0 <namei>
801056c8:	83 c4 10             	add    $0x10,%esp
801056cb:	89 c3                	mov    %eax,%ebx
801056cd:	85 c0                	test   %eax,%eax
801056cf:	0f 84 e4 00 00 00    	je     801057b9 <sys_link+0x139>
  ilock(ip);
801056d5:	83 ec 0c             	sub    $0xc,%esp
801056d8:	50                   	push   %eax
801056d9:	e8 a2 c0 ff ff       	call   80101780 <ilock>
  if(ip->type == T_DIR){
801056de:	83 c4 10             	add    $0x10,%esp
801056e1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801056e6:	0f 84 b5 00 00 00    	je     801057a1 <sys_link+0x121>
  iupdate(ip);
801056ec:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
801056ef:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
801056f4:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
801056f7:	53                   	push   %ebx
801056f8:	e8 d3 bf ff ff       	call   801016d0 <iupdate>
  iunlock(ip);
801056fd:	89 1c 24             	mov    %ebx,(%esp)
80105700:	e8 5b c1 ff ff       	call   80101860 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80105705:	58                   	pop    %eax
80105706:	5a                   	pop    %edx
80105707:	57                   	push   %edi
80105708:	ff 75 d0             	push   -0x30(%ebp)
8010570b:	e8 b0 c9 ff ff       	call   801020c0 <nameiparent>
80105710:	83 c4 10             	add    $0x10,%esp
80105713:	89 c6                	mov    %eax,%esi
80105715:	85 c0                	test   %eax,%eax
80105717:	74 5b                	je     80105774 <sys_link+0xf4>
  ilock(dp);
80105719:	83 ec 0c             	sub    $0xc,%esp
8010571c:	50                   	push   %eax
8010571d:	e8 5e c0 ff ff       	call   80101780 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105722:	8b 03                	mov    (%ebx),%eax
80105724:	83 c4 10             	add    $0x10,%esp
80105727:	39 06                	cmp    %eax,(%esi)
80105729:	75 3d                	jne    80105768 <sys_link+0xe8>
8010572b:	83 ec 04             	sub    $0x4,%esp
8010572e:	ff 73 04             	push   0x4(%ebx)
80105731:	57                   	push   %edi
80105732:	56                   	push   %esi
80105733:	e8 a8 c8 ff ff       	call   80101fe0 <dirlink>
80105738:	83 c4 10             	add    $0x10,%esp
8010573b:	85 c0                	test   %eax,%eax
8010573d:	78 29                	js     80105768 <sys_link+0xe8>
  iunlockput(dp);
8010573f:	83 ec 0c             	sub    $0xc,%esp
80105742:	56                   	push   %esi
80105743:	e8 c8 c2 ff ff       	call   80101a10 <iunlockput>
  iput(ip);
80105748:	89 1c 24             	mov    %ebx,(%esp)
8010574b:	e8 60 c1 ff ff       	call   801018b0 <iput>
  end_op();
80105750:	e8 7b d6 ff ff       	call   80102dd0 <end_op>
  return 0;
80105755:	83 c4 10             	add    $0x10,%esp
80105758:	31 c0                	xor    %eax,%eax
}
8010575a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010575d:	5b                   	pop    %ebx
8010575e:	5e                   	pop    %esi
8010575f:	5f                   	pop    %edi
80105760:	5d                   	pop    %ebp
80105761:	c3                   	ret    
80105762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105768:	83 ec 0c             	sub    $0xc,%esp
8010576b:	56                   	push   %esi
8010576c:	e8 9f c2 ff ff       	call   80101a10 <iunlockput>
    goto bad;
80105771:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105774:	83 ec 0c             	sub    $0xc,%esp
80105777:	53                   	push   %ebx
80105778:	e8 03 c0 ff ff       	call   80101780 <ilock>
  ip->nlink--;
8010577d:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105782:	89 1c 24             	mov    %ebx,(%esp)
80105785:	e8 46 bf ff ff       	call   801016d0 <iupdate>
  iunlockput(ip);
8010578a:	89 1c 24             	mov    %ebx,(%esp)
8010578d:	e8 7e c2 ff ff       	call   80101a10 <iunlockput>
  end_op();
80105792:	e8 39 d6 ff ff       	call   80102dd0 <end_op>
  return -1;
80105797:	83 c4 10             	add    $0x10,%esp
8010579a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579f:	eb b9                	jmp    8010575a <sys_link+0xda>
    iunlockput(ip);
801057a1:	83 ec 0c             	sub    $0xc,%esp
801057a4:	53                   	push   %ebx
801057a5:	e8 66 c2 ff ff       	call   80101a10 <iunlockput>
    end_op();
801057aa:	e8 21 d6 ff ff       	call   80102dd0 <end_op>
    return -1;
801057af:	83 c4 10             	add    $0x10,%esp
801057b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b7:	eb a1                	jmp    8010575a <sys_link+0xda>
    end_op();
801057b9:	e8 12 d6 ff ff       	call   80102dd0 <end_op>
    return -1;
801057be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c3:	eb 95                	jmp    8010575a <sys_link+0xda>
801057c5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801057cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801057d0 <sys_unlink>:
{
801057d0:	55                   	push   %ebp
801057d1:	89 e5                	mov    %esp,%ebp
801057d3:	57                   	push   %edi
801057d4:	56                   	push   %esi
  if(argstr(0, &path) < 0)
801057d5:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
801057d8:	53                   	push   %ebx
801057d9:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
801057dc:	50                   	push   %eax
801057dd:	6a 00                	push   $0x0
801057df:	e8 bc f9 ff ff       	call   801051a0 <argstr>
801057e4:	83 c4 10             	add    $0x10,%esp
801057e7:	85 c0                	test   %eax,%eax
801057e9:	0f 88 7a 01 00 00    	js     80105969 <sys_unlink+0x199>
  begin_op();
801057ef:	e8 6c d5 ff ff       	call   80102d60 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801057f4:	8d 5d ca             	lea    -0x36(%ebp),%ebx
801057f7:	83 ec 08             	sub    $0x8,%esp
801057fa:	53                   	push   %ebx
801057fb:	ff 75 c0             	push   -0x40(%ebp)
801057fe:	e8 bd c8 ff ff       	call   801020c0 <nameiparent>
80105803:	83 c4 10             	add    $0x10,%esp
80105806:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80105809:	85 c0                	test   %eax,%eax
8010580b:	0f 84 62 01 00 00    	je     80105973 <sys_unlink+0x1a3>
  ilock(dp);
80105811:	8b 7d b4             	mov    -0x4c(%ebp),%edi
80105814:	83 ec 0c             	sub    $0xc,%esp
80105817:	57                   	push   %edi
80105818:	e8 63 bf ff ff       	call   80101780 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010581d:	58                   	pop    %eax
8010581e:	5a                   	pop    %edx
8010581f:	68 0c 87 10 80       	push   $0x8010870c
80105824:	53                   	push   %ebx
80105825:	e8 96 c4 ff ff       	call   80101cc0 <namecmp>
8010582a:	83 c4 10             	add    $0x10,%esp
8010582d:	85 c0                	test   %eax,%eax
8010582f:	0f 84 fb 00 00 00    	je     80105930 <sys_unlink+0x160>
80105835:	83 ec 08             	sub    $0x8,%esp
80105838:	68 0b 87 10 80       	push   $0x8010870b
8010583d:	53                   	push   %ebx
8010583e:	e8 7d c4 ff ff       	call   80101cc0 <namecmp>
80105843:	83 c4 10             	add    $0x10,%esp
80105846:	85 c0                	test   %eax,%eax
80105848:	0f 84 e2 00 00 00    	je     80105930 <sys_unlink+0x160>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010584e:	83 ec 04             	sub    $0x4,%esp
80105851:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105854:	50                   	push   %eax
80105855:	53                   	push   %ebx
80105856:	57                   	push   %edi
80105857:	e8 84 c4 ff ff       	call   80101ce0 <dirlookup>
8010585c:	83 c4 10             	add    $0x10,%esp
8010585f:	89 c3                	mov    %eax,%ebx
80105861:	85 c0                	test   %eax,%eax
80105863:	0f 84 c7 00 00 00    	je     80105930 <sys_unlink+0x160>
  ilock(ip);
80105869:	83 ec 0c             	sub    $0xc,%esp
8010586c:	50                   	push   %eax
8010586d:	e8 0e bf ff ff       	call   80101780 <ilock>
  if(ip->nlink < 1)
80105872:	83 c4 10             	add    $0x10,%esp
80105875:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010587a:	0f 8e 1c 01 00 00    	jle    8010599c <sys_unlink+0x1cc>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105880:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105885:	8d 7d d8             	lea    -0x28(%ebp),%edi
80105888:	74 66                	je     801058f0 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
8010588a:	83 ec 04             	sub    $0x4,%esp
8010588d:	6a 10                	push   $0x10
8010588f:	6a 00                	push   $0x0
80105891:	57                   	push   %edi
80105892:	e8 89 f5 ff ff       	call   80104e20 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105897:	6a 10                	push   $0x10
80105899:	ff 75 c4             	push   -0x3c(%ebp)
8010589c:	57                   	push   %edi
8010589d:	ff 75 b4             	push   -0x4c(%ebp)
801058a0:	e8 eb c2 ff ff       	call   80101b90 <writei>
801058a5:	83 c4 20             	add    $0x20,%esp
801058a8:	83 f8 10             	cmp    $0x10,%eax
801058ab:	0f 85 de 00 00 00    	jne    8010598f <sys_unlink+0x1bf>
  if(ip->type == T_DIR){
801058b1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801058b6:	0f 84 94 00 00 00    	je     80105950 <sys_unlink+0x180>
  iunlockput(dp);
801058bc:	83 ec 0c             	sub    $0xc,%esp
801058bf:	ff 75 b4             	push   -0x4c(%ebp)
801058c2:	e8 49 c1 ff ff       	call   80101a10 <iunlockput>
  ip->nlink--;
801058c7:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
801058cc:	89 1c 24             	mov    %ebx,(%esp)
801058cf:	e8 fc bd ff ff       	call   801016d0 <iupdate>
  iunlockput(ip);
801058d4:	89 1c 24             	mov    %ebx,(%esp)
801058d7:	e8 34 c1 ff ff       	call   80101a10 <iunlockput>
  end_op();
801058dc:	e8 ef d4 ff ff       	call   80102dd0 <end_op>
  return 0;
801058e1:	83 c4 10             	add    $0x10,%esp
801058e4:	31 c0                	xor    %eax,%eax
}
801058e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801058e9:	5b                   	pop    %ebx
801058ea:	5e                   	pop    %esi
801058eb:	5f                   	pop    %edi
801058ec:	5d                   	pop    %ebp
801058ed:	c3                   	ret    
801058ee:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058f0:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
801058f4:	76 94                	jbe    8010588a <sys_unlink+0xba>
801058f6:	be 20 00 00 00       	mov    $0x20,%esi
801058fb:	eb 0b                	jmp    80105908 <sys_unlink+0x138>
801058fd:	8d 76 00             	lea    0x0(%esi),%esi
80105900:	83 c6 10             	add    $0x10,%esi
80105903:	3b 73 58             	cmp    0x58(%ebx),%esi
80105906:	73 82                	jae    8010588a <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105908:	6a 10                	push   $0x10
8010590a:	56                   	push   %esi
8010590b:	57                   	push   %edi
8010590c:	53                   	push   %ebx
8010590d:	e8 7e c1 ff ff       	call   80101a90 <readi>
80105912:	83 c4 10             	add    $0x10,%esp
80105915:	83 f8 10             	cmp    $0x10,%eax
80105918:	75 68                	jne    80105982 <sys_unlink+0x1b2>
    if(de.inum != 0)
8010591a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010591f:	74 df                	je     80105900 <sys_unlink+0x130>
    iunlockput(ip);
80105921:	83 ec 0c             	sub    $0xc,%esp
80105924:	53                   	push   %ebx
80105925:	e8 e6 c0 ff ff       	call   80101a10 <iunlockput>
    goto bad;
8010592a:	83 c4 10             	add    $0x10,%esp
8010592d:	8d 76 00             	lea    0x0(%esi),%esi
  iunlockput(dp);
80105930:	83 ec 0c             	sub    $0xc,%esp
80105933:	ff 75 b4             	push   -0x4c(%ebp)
80105936:	e8 d5 c0 ff ff       	call   80101a10 <iunlockput>
  end_op();
8010593b:	e8 90 d4 ff ff       	call   80102dd0 <end_op>
  return -1;
80105940:	83 c4 10             	add    $0x10,%esp
80105943:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105948:	eb 9c                	jmp    801058e6 <sys_unlink+0x116>
8010594a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    dp->nlink--;
80105950:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
80105953:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105956:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
8010595b:	50                   	push   %eax
8010595c:	e8 6f bd ff ff       	call   801016d0 <iupdate>
80105961:	83 c4 10             	add    $0x10,%esp
80105964:	e9 53 ff ff ff       	jmp    801058bc <sys_unlink+0xec>
    return -1;
80105969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596e:	e9 73 ff ff ff       	jmp    801058e6 <sys_unlink+0x116>
    end_op();
80105973:	e8 58 d4 ff ff       	call   80102dd0 <end_op>
    return -1;
80105978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010597d:	e9 64 ff ff ff       	jmp    801058e6 <sys_unlink+0x116>
      panic("isdirempty: readi");
80105982:	83 ec 0c             	sub    $0xc,%esp
80105985:	68 30 87 10 80       	push   $0x80108730
8010598a:	e8 f1 a9 ff ff       	call   80100380 <panic>
    panic("unlink: writei");
8010598f:	83 ec 0c             	sub    $0xc,%esp
80105992:	68 42 87 10 80       	push   $0x80108742
80105997:	e8 e4 a9 ff ff       	call   80100380 <panic>
    panic("unlink: nlink < 1");
8010599c:	83 ec 0c             	sub    $0xc,%esp
8010599f:	68 1e 87 10 80       	push   $0x8010871e
801059a4:	e8 d7 a9 ff ff       	call   80100380 <panic>
801059a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801059b0 <sys_open>:

int
sys_open(void)
{
801059b0:	55                   	push   %ebp
801059b1:	89 e5                	mov    %esp,%ebp
801059b3:	57                   	push   %edi
801059b4:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801059b5:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
801059b8:	53                   	push   %ebx
801059b9:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801059bc:	50                   	push   %eax
801059bd:	6a 00                	push   $0x0
801059bf:	e8 dc f7 ff ff       	call   801051a0 <argstr>
801059c4:	83 c4 10             	add    $0x10,%esp
801059c7:	85 c0                	test   %eax,%eax
801059c9:	0f 88 8e 00 00 00    	js     80105a5d <sys_open+0xad>
801059cf:	83 ec 08             	sub    $0x8,%esp
801059d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801059d5:	50                   	push   %eax
801059d6:	6a 01                	push   $0x1
801059d8:	e8 03 f7 ff ff       	call   801050e0 <argint>
801059dd:	83 c4 10             	add    $0x10,%esp
801059e0:	85 c0                	test   %eax,%eax
801059e2:	78 79                	js     80105a5d <sys_open+0xad>
    return -1;

  begin_op();
801059e4:	e8 77 d3 ff ff       	call   80102d60 <begin_op>

  if(omode & O_CREATE){
801059e9:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801059ed:	75 79                	jne    80105a68 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801059ef:	83 ec 0c             	sub    $0xc,%esp
801059f2:	ff 75 e0             	push   -0x20(%ebp)
801059f5:	e8 a6 c6 ff ff       	call   801020a0 <namei>
801059fa:	83 c4 10             	add    $0x10,%esp
801059fd:	89 c6                	mov    %eax,%esi
801059ff:	85 c0                	test   %eax,%eax
80105a01:	0f 84 7e 00 00 00    	je     80105a85 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
80105a07:	83 ec 0c             	sub    $0xc,%esp
80105a0a:	50                   	push   %eax
80105a0b:	e8 70 bd ff ff       	call   80101780 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105a10:	83 c4 10             	add    $0x10,%esp
80105a13:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80105a18:	0f 84 c2 00 00 00    	je     80105ae0 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105a1e:	e8 0d b4 ff ff       	call   80100e30 <filealloc>
80105a23:	89 c7                	mov    %eax,%edi
80105a25:	85 c0                	test   %eax,%eax
80105a27:	74 23                	je     80105a4c <sys_open+0x9c>
  struct proc *curproc = myproc();
80105a29:	e8 a2 df ff ff       	call   801039d0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105a2e:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80105a30:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80105a34:	85 d2                	test   %edx,%edx
80105a36:	74 60                	je     80105a98 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
80105a38:	83 c3 01             	add    $0x1,%ebx
80105a3b:	83 fb 10             	cmp    $0x10,%ebx
80105a3e:	75 f0                	jne    80105a30 <sys_open+0x80>
    if(f)
      fileclose(f);
80105a40:	83 ec 0c             	sub    $0xc,%esp
80105a43:	57                   	push   %edi
80105a44:	e8 a7 b4 ff ff       	call   80100ef0 <fileclose>
80105a49:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105a4c:	83 ec 0c             	sub    $0xc,%esp
80105a4f:	56                   	push   %esi
80105a50:	e8 bb bf ff ff       	call   80101a10 <iunlockput>
    end_op();
80105a55:	e8 76 d3 ff ff       	call   80102dd0 <end_op>
    return -1;
80105a5a:	83 c4 10             	add    $0x10,%esp
80105a5d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105a62:	eb 6d                	jmp    80105ad1 <sys_open+0x121>
80105a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80105a68:	83 ec 0c             	sub    $0xc,%esp
80105a6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105a6e:	31 c9                	xor    %ecx,%ecx
80105a70:	ba 02 00 00 00       	mov    $0x2,%edx
80105a75:	6a 00                	push   $0x0
80105a77:	e8 14 f8 ff ff       	call   80105290 <create>
    if(ip == 0){
80105a7c:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
80105a7f:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105a81:	85 c0                	test   %eax,%eax
80105a83:	75 99                	jne    80105a1e <sys_open+0x6e>
      end_op();
80105a85:	e8 46 d3 ff ff       	call   80102dd0 <end_op>
      return -1;
80105a8a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105a8f:	eb 40                	jmp    80105ad1 <sys_open+0x121>
80105a91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
80105a98:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
80105a9b:	89 7c 98 28          	mov    %edi,0x28(%eax,%ebx,4)
  iunlock(ip);
80105a9f:	56                   	push   %esi
80105aa0:	e8 bb bd ff ff       	call   80101860 <iunlock>
  end_op();
80105aa5:	e8 26 d3 ff ff       	call   80102dd0 <end_op>

  f->type = FD_INODE;
80105aaa:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
80105ab0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105ab3:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105ab6:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
80105ab9:	89 d0                	mov    %edx,%eax
  f->off = 0;
80105abb:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
80105ac2:	f7 d0                	not    %eax
80105ac4:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105ac7:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
80105aca:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105acd:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
80105ad1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ad4:	89 d8                	mov    %ebx,%eax
80105ad6:	5b                   	pop    %ebx
80105ad7:	5e                   	pop    %esi
80105ad8:	5f                   	pop    %edi
80105ad9:	5d                   	pop    %ebp
80105ada:	c3                   	ret    
80105adb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105adf:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
80105ae0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105ae3:	85 c9                	test   %ecx,%ecx
80105ae5:	0f 84 33 ff ff ff    	je     80105a1e <sys_open+0x6e>
80105aeb:	e9 5c ff ff ff       	jmp    80105a4c <sys_open+0x9c>

80105af0 <sys_mkdir>:

int
sys_mkdir(void)
{
80105af0:	55                   	push   %ebp
80105af1:	89 e5                	mov    %esp,%ebp
80105af3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105af6:	e8 65 d2 ff ff       	call   80102d60 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105afb:	83 ec 08             	sub    $0x8,%esp
80105afe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b01:	50                   	push   %eax
80105b02:	6a 00                	push   $0x0
80105b04:	e8 97 f6 ff ff       	call   801051a0 <argstr>
80105b09:	83 c4 10             	add    $0x10,%esp
80105b0c:	85 c0                	test   %eax,%eax
80105b0e:	78 30                	js     80105b40 <sys_mkdir+0x50>
80105b10:	83 ec 0c             	sub    $0xc,%esp
80105b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b16:	31 c9                	xor    %ecx,%ecx
80105b18:	ba 01 00 00 00       	mov    $0x1,%edx
80105b1d:	6a 00                	push   $0x0
80105b1f:	e8 6c f7 ff ff       	call   80105290 <create>
80105b24:	83 c4 10             	add    $0x10,%esp
80105b27:	85 c0                	test   %eax,%eax
80105b29:	74 15                	je     80105b40 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
80105b2b:	83 ec 0c             	sub    $0xc,%esp
80105b2e:	50                   	push   %eax
80105b2f:	e8 dc be ff ff       	call   80101a10 <iunlockput>
  end_op();
80105b34:	e8 97 d2 ff ff       	call   80102dd0 <end_op>
  return 0;
80105b39:	83 c4 10             	add    $0x10,%esp
80105b3c:	31 c0                	xor    %eax,%eax
}
80105b3e:	c9                   	leave  
80105b3f:	c3                   	ret    
    end_op();
80105b40:	e8 8b d2 ff ff       	call   80102dd0 <end_op>
    return -1;
80105b45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b4a:	c9                   	leave  
80105b4b:	c3                   	ret    
80105b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105b50 <sys_mknod>:

int
sys_mknod(void)
{
80105b50:	55                   	push   %ebp
80105b51:	89 e5                	mov    %esp,%ebp
80105b53:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105b56:	e8 05 d2 ff ff       	call   80102d60 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105b5b:	83 ec 08             	sub    $0x8,%esp
80105b5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b61:	50                   	push   %eax
80105b62:	6a 00                	push   $0x0
80105b64:	e8 37 f6 ff ff       	call   801051a0 <argstr>
80105b69:	83 c4 10             	add    $0x10,%esp
80105b6c:	85 c0                	test   %eax,%eax
80105b6e:	78 60                	js     80105bd0 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105b70:	83 ec 08             	sub    $0x8,%esp
80105b73:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b76:	50                   	push   %eax
80105b77:	6a 01                	push   $0x1
80105b79:	e8 62 f5 ff ff       	call   801050e0 <argint>
  if((argstr(0, &path)) < 0 ||
80105b7e:	83 c4 10             	add    $0x10,%esp
80105b81:	85 c0                	test   %eax,%eax
80105b83:	78 4b                	js     80105bd0 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105b85:	83 ec 08             	sub    $0x8,%esp
80105b88:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b8b:	50                   	push   %eax
80105b8c:	6a 02                	push   $0x2
80105b8e:	e8 4d f5 ff ff       	call   801050e0 <argint>
     argint(1, &major) < 0 ||
80105b93:	83 c4 10             	add    $0x10,%esp
80105b96:	85 c0                	test   %eax,%eax
80105b98:	78 36                	js     80105bd0 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105b9a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
80105b9e:	83 ec 0c             	sub    $0xc,%esp
80105ba1:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80105ba5:	ba 03 00 00 00       	mov    $0x3,%edx
80105baa:	50                   	push   %eax
80105bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105bae:	e8 dd f6 ff ff       	call   80105290 <create>
     argint(2, &minor) < 0 ||
80105bb3:	83 c4 10             	add    $0x10,%esp
80105bb6:	85 c0                	test   %eax,%eax
80105bb8:	74 16                	je     80105bd0 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
80105bba:	83 ec 0c             	sub    $0xc,%esp
80105bbd:	50                   	push   %eax
80105bbe:	e8 4d be ff ff       	call   80101a10 <iunlockput>
  end_op();
80105bc3:	e8 08 d2 ff ff       	call   80102dd0 <end_op>
  return 0;
80105bc8:	83 c4 10             	add    $0x10,%esp
80105bcb:	31 c0                	xor    %eax,%eax
}
80105bcd:	c9                   	leave  
80105bce:	c3                   	ret    
80105bcf:	90                   	nop
    end_op();
80105bd0:	e8 fb d1 ff ff       	call   80102dd0 <end_op>
    return -1;
80105bd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bda:	c9                   	leave  
80105bdb:	c3                   	ret    
80105bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105be0 <sys_chdir>:

int
sys_chdir(void)
{
80105be0:	55                   	push   %ebp
80105be1:	89 e5                	mov    %esp,%ebp
80105be3:	56                   	push   %esi
80105be4:	53                   	push   %ebx
80105be5:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105be8:	e8 e3 dd ff ff       	call   801039d0 <myproc>
80105bed:	89 c6                	mov    %eax,%esi
  
  begin_op();
80105bef:	e8 6c d1 ff ff       	call   80102d60 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105bf4:	83 ec 08             	sub    $0x8,%esp
80105bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bfa:	50                   	push   %eax
80105bfb:	6a 00                	push   $0x0
80105bfd:	e8 9e f5 ff ff       	call   801051a0 <argstr>
80105c02:	83 c4 10             	add    $0x10,%esp
80105c05:	85 c0                	test   %eax,%eax
80105c07:	78 77                	js     80105c80 <sys_chdir+0xa0>
80105c09:	83 ec 0c             	sub    $0xc,%esp
80105c0c:	ff 75 f4             	push   -0xc(%ebp)
80105c0f:	e8 8c c4 ff ff       	call   801020a0 <namei>
80105c14:	83 c4 10             	add    $0x10,%esp
80105c17:	89 c3                	mov    %eax,%ebx
80105c19:	85 c0                	test   %eax,%eax
80105c1b:	74 63                	je     80105c80 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
80105c1d:	83 ec 0c             	sub    $0xc,%esp
80105c20:	50                   	push   %eax
80105c21:	e8 5a bb ff ff       	call   80101780 <ilock>
  if(ip->type != T_DIR){
80105c26:	83 c4 10             	add    $0x10,%esp
80105c29:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105c2e:	75 30                	jne    80105c60 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105c30:	83 ec 0c             	sub    $0xc,%esp
80105c33:	53                   	push   %ebx
80105c34:	e8 27 bc ff ff       	call   80101860 <iunlock>
  iput(curproc->cwd);
80105c39:	58                   	pop    %eax
80105c3a:	ff 76 68             	push   0x68(%esi)
80105c3d:	e8 6e bc ff ff       	call   801018b0 <iput>
  end_op();
80105c42:	e8 89 d1 ff ff       	call   80102dd0 <end_op>
  curproc->cwd = ip;
80105c47:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80105c4a:	83 c4 10             	add    $0x10,%esp
80105c4d:	31 c0                	xor    %eax,%eax
}
80105c4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105c52:	5b                   	pop    %ebx
80105c53:	5e                   	pop    %esi
80105c54:	5d                   	pop    %ebp
80105c55:	c3                   	ret    
80105c56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c5d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105c60:	83 ec 0c             	sub    $0xc,%esp
80105c63:	53                   	push   %ebx
80105c64:	e8 a7 bd ff ff       	call   80101a10 <iunlockput>
    end_op();
80105c69:	e8 62 d1 ff ff       	call   80102dd0 <end_op>
    return -1;
80105c6e:	83 c4 10             	add    $0x10,%esp
80105c71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c76:	eb d7                	jmp    80105c4f <sys_chdir+0x6f>
80105c78:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c7f:	90                   	nop
    end_op();
80105c80:	e8 4b d1 ff ff       	call   80102dd0 <end_op>
    return -1;
80105c85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c8a:	eb c3                	jmp    80105c4f <sys_chdir+0x6f>
80105c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105c90 <sys_exec>:

int
sys_exec(void)
{
80105c90:	55                   	push   %ebp
80105c91:	89 e5                	mov    %esp,%ebp
80105c93:	57                   	push   %edi
80105c94:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105c95:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
80105c9b:	53                   	push   %ebx
80105c9c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ca2:	50                   	push   %eax
80105ca3:	6a 00                	push   $0x0
80105ca5:	e8 f6 f4 ff ff       	call   801051a0 <argstr>
80105caa:	83 c4 10             	add    $0x10,%esp
80105cad:	85 c0                	test   %eax,%eax
80105caf:	0f 88 87 00 00 00    	js     80105d3c <sys_exec+0xac>
80105cb5:	83 ec 08             	sub    $0x8,%esp
80105cb8:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80105cbe:	50                   	push   %eax
80105cbf:	6a 01                	push   $0x1
80105cc1:	e8 1a f4 ff ff       	call   801050e0 <argint>
80105cc6:	83 c4 10             	add    $0x10,%esp
80105cc9:	85 c0                	test   %eax,%eax
80105ccb:	78 6f                	js     80105d3c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80105ccd:	83 ec 04             	sub    $0x4,%esp
80105cd0:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  for(i=0;; i++){
80105cd6:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105cd8:	68 80 00 00 00       	push   $0x80
80105cdd:	6a 00                	push   $0x0
80105cdf:	56                   	push   %esi
80105ce0:	e8 3b f1 ff ff       	call   80104e20 <memset>
80105ce5:	83 c4 10             	add    $0x10,%esp
80105ce8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cef:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105cf0:	83 ec 08             	sub    $0x8,%esp
80105cf3:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80105cf9:	8d 3c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edi
80105d00:	50                   	push   %eax
80105d01:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105d07:	01 f8                	add    %edi,%eax
80105d09:	50                   	push   %eax
80105d0a:	e8 41 f3 ff ff       	call   80105050 <fetchint>
80105d0f:	83 c4 10             	add    $0x10,%esp
80105d12:	85 c0                	test   %eax,%eax
80105d14:	78 26                	js     80105d3c <sys_exec+0xac>
      return -1;
    if(uarg == 0){
80105d16:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105d1c:	85 c0                	test   %eax,%eax
80105d1e:	74 30                	je     80105d50 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105d20:	83 ec 08             	sub    $0x8,%esp
80105d23:	8d 14 3e             	lea    (%esi,%edi,1),%edx
80105d26:	52                   	push   %edx
80105d27:	50                   	push   %eax
80105d28:	e8 63 f3 ff ff       	call   80105090 <fetchstr>
80105d2d:	83 c4 10             	add    $0x10,%esp
80105d30:	85 c0                	test   %eax,%eax
80105d32:	78 08                	js     80105d3c <sys_exec+0xac>
  for(i=0;; i++){
80105d34:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105d37:	83 fb 20             	cmp    $0x20,%ebx
80105d3a:	75 b4                	jne    80105cf0 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
80105d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
80105d3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d44:	5b                   	pop    %ebx
80105d45:	5e                   	pop    %esi
80105d46:	5f                   	pop    %edi
80105d47:	5d                   	pop    %ebp
80105d48:	c3                   	ret    
80105d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      argv[i] = 0;
80105d50:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105d57:	00 00 00 00 
  return exec(path, argv);
80105d5b:	83 ec 08             	sub    $0x8,%esp
80105d5e:	56                   	push   %esi
80105d5f:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
80105d65:	e8 46 ad ff ff       	call   80100ab0 <exec>
80105d6a:	83 c4 10             	add    $0x10,%esp
}
80105d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d70:	5b                   	pop    %ebx
80105d71:	5e                   	pop    %esi
80105d72:	5f                   	pop    %edi
80105d73:	5d                   	pop    %ebp
80105d74:	c3                   	ret    
80105d75:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105d80 <sys_pipe>:

int
sys_pipe(void)
{
80105d80:	55                   	push   %ebp
80105d81:	89 e5                	mov    %esp,%ebp
80105d83:	57                   	push   %edi
80105d84:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105d85:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105d88:	53                   	push   %ebx
80105d89:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105d8c:	6a 08                	push   $0x8
80105d8e:	50                   	push   %eax
80105d8f:	6a 00                	push   $0x0
80105d91:	e8 9a f3 ff ff       	call   80105130 <argptr>
80105d96:	83 c4 10             	add    $0x10,%esp
80105d99:	85 c0                	test   %eax,%eax
80105d9b:	78 4a                	js     80105de7 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105d9d:	83 ec 08             	sub    $0x8,%esp
80105da0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105da3:	50                   	push   %eax
80105da4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105da7:	50                   	push   %eax
80105da8:	e8 83 d6 ff ff       	call   80103430 <pipealloc>
80105dad:	83 c4 10             	add    $0x10,%esp
80105db0:	85 c0                	test   %eax,%eax
80105db2:	78 33                	js     80105de7 <sys_pipe+0x67>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105db4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105db7:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80105db9:	e8 12 dc ff ff       	call   801039d0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105dbe:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105dc0:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
80105dc4:	85 f6                	test   %esi,%esi
80105dc6:	74 28                	je     80105df0 <sys_pipe+0x70>
  for(fd = 0; fd < NOFILE; fd++){
80105dc8:	83 c3 01             	add    $0x1,%ebx
80105dcb:	83 fb 10             	cmp    $0x10,%ebx
80105dce:	75 f0                	jne    80105dc0 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80105dd0:	83 ec 0c             	sub    $0xc,%esp
80105dd3:	ff 75 e0             	push   -0x20(%ebp)
80105dd6:	e8 15 b1 ff ff       	call   80100ef0 <fileclose>
    fileclose(wf);
80105ddb:	58                   	pop    %eax
80105ddc:	ff 75 e4             	push   -0x1c(%ebp)
80105ddf:	e8 0c b1 ff ff       	call   80100ef0 <fileclose>
    return -1;
80105de4:	83 c4 10             	add    $0x10,%esp
80105de7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dec:	eb 53                	jmp    80105e41 <sys_pipe+0xc1>
80105dee:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105df0:	8d 73 08             	lea    0x8(%ebx),%esi
80105df3:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105df7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
80105dfa:	e8 d1 db ff ff       	call   801039d0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105dff:	31 d2                	xor    %edx,%edx
80105e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80105e08:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
80105e0c:	85 c9                	test   %ecx,%ecx
80105e0e:	74 20                	je     80105e30 <sys_pipe+0xb0>
  for(fd = 0; fd < NOFILE; fd++){
80105e10:	83 c2 01             	add    $0x1,%edx
80105e13:	83 fa 10             	cmp    $0x10,%edx
80105e16:	75 f0                	jne    80105e08 <sys_pipe+0x88>
      myproc()->ofile[fd0] = 0;
80105e18:	e8 b3 db ff ff       	call   801039d0 <myproc>
80105e1d:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
80105e24:	00 
80105e25:	eb a9                	jmp    80105dd0 <sys_pipe+0x50>
80105e27:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e2e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105e30:	89 7c 90 28          	mov    %edi,0x28(%eax,%edx,4)
  }
  fd[0] = fd0;
80105e34:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e37:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105e39:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e3c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105e3f:	31 c0                	xor    %eax,%eax
}
80105e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e44:	5b                   	pop    %ebx
80105e45:	5e                   	pop    %esi
80105e46:	5f                   	pop    %edi
80105e47:	5d                   	pop    %ebp
80105e48:	c3                   	ret    
80105e49:	66 90                	xchg   %ax,%ax
80105e4b:	66 90                	xchg   %ax,%ax
80105e4d:	66 90                	xchg   %ax,%ax
80105e4f:	90                   	nop

80105e50 <sys_fork>:
#include "proc.h"

int
sys_fork(void)
{
  return fork();
80105e50:	e9 1b dd ff ff       	jmp    80103b70 <fork>
80105e55:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105e60 <sys_exit>:
}

int
sys_exit(void)
{
80105e60:	55                   	push   %ebp
80105e61:	89 e5                	mov    %esp,%ebp
80105e63:	83 ec 08             	sub    $0x8,%esp
  exit();
80105e66:	e8 75 e2 ff ff       	call   801040e0 <exit>
  return 0;  // not reached
}
80105e6b:	31 c0                	xor    %eax,%eax
80105e6d:	c9                   	leave  
80105e6e:	c3                   	ret    
80105e6f:	90                   	nop

80105e70 <sys_wait>:

int
sys_wait(void)
{
  return wait();
80105e70:	e9 9b e3 ff ff       	jmp    80104210 <wait>
80105e75:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105e80 <sys_kill>:
}

int
sys_kill(void)
{
80105e80:	55                   	push   %ebp
80105e81:	89 e5                	mov    %esp,%ebp
80105e83:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e89:	50                   	push   %eax
80105e8a:	6a 00                	push   $0x0
80105e8c:	e8 4f f2 ff ff       	call   801050e0 <argint>
80105e91:	83 c4 10             	add    $0x10,%esp
80105e94:	85 c0                	test   %eax,%eax
80105e96:	78 18                	js     80105eb0 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105e98:	83 ec 0c             	sub    $0xc,%esp
80105e9b:	ff 75 f4             	push   -0xc(%ebp)
80105e9e:	e8 2d e6 ff ff       	call   801044d0 <kill>
80105ea3:	83 c4 10             	add    $0x10,%esp
}
80105ea6:	c9                   	leave  
80105ea7:	c3                   	ret    
80105ea8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105eaf:	90                   	nop
80105eb0:	c9                   	leave  
    return -1;
80105eb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105eb6:	c3                   	ret    
80105eb7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105ebe:	66 90                	xchg   %ax,%ax

80105ec0 <sys_getpid>:

int
sys_getpid(void)
{
80105ec0:	55                   	push   %ebp
80105ec1:	89 e5                	mov    %esp,%ebp
80105ec3:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105ec6:	e8 05 db ff ff       	call   801039d0 <myproc>
80105ecb:	8b 40 10             	mov    0x10(%eax),%eax
}
80105ece:	c9                   	leave  
80105ecf:	c3                   	ret    

80105ed0 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ed0:	55                   	push   %ebp
80105ed1:	89 e5                	mov    %esp,%ebp
80105ed3:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ed4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105ed7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105eda:	50                   	push   %eax
80105edb:	6a 00                	push   $0x0
80105edd:	e8 fe f1 ff ff       	call   801050e0 <argint>
80105ee2:	83 c4 10             	add    $0x10,%esp
80105ee5:	85 c0                	test   %eax,%eax
80105ee7:	78 27                	js     80105f10 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105ee9:	e8 e2 da ff ff       	call   801039d0 <myproc>
  if(growproc(n) < 0)
80105eee:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105ef1:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105ef3:	ff 75 f4             	push   -0xc(%ebp)
80105ef6:	e8 f5 db ff ff       	call   80103af0 <growproc>
80105efb:	83 c4 10             	add    $0x10,%esp
80105efe:	85 c0                	test   %eax,%eax
80105f00:	78 0e                	js     80105f10 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105f02:	89 d8                	mov    %ebx,%eax
80105f04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105f07:	c9                   	leave  
80105f08:	c3                   	ret    
80105f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105f10:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105f15:	eb eb                	jmp    80105f02 <sys_sbrk+0x32>
80105f17:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105f1e:	66 90                	xchg   %ax,%ax

80105f20 <sys_sleep>:

int
sys_sleep(void)
{
80105f20:	55                   	push   %ebp
80105f21:	89 e5                	mov    %esp,%ebp
80105f23:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105f24:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105f27:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105f2a:	50                   	push   %eax
80105f2b:	6a 00                	push   $0x0
80105f2d:	e8 ae f1 ff ff       	call   801050e0 <argint>
80105f32:	83 c4 10             	add    $0x10,%esp
80105f35:	85 c0                	test   %eax,%eax
80105f37:	0f 88 8a 00 00 00    	js     80105fc7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105f3d:	83 ec 0c             	sub    $0xc,%esp
80105f40:	68 e0 53 11 80       	push   $0x801153e0
80105f45:	e8 16 ee ff ff       	call   80104d60 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105f4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
80105f4d:	8b 1d c0 53 11 80    	mov    0x801153c0,%ebx
  while(ticks - ticks0 < n){
80105f53:	83 c4 10             	add    $0x10,%esp
80105f56:	85 d2                	test   %edx,%edx
80105f58:	75 27                	jne    80105f81 <sys_sleep+0x61>
80105f5a:	eb 54                	jmp    80105fb0 <sys_sleep+0x90>
80105f5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105f60:	83 ec 08             	sub    $0x8,%esp
80105f63:	68 e0 53 11 80       	push   $0x801153e0
80105f68:	68 c0 53 11 80       	push   $0x801153c0
80105f6d:	e8 3e e4 ff ff       	call   801043b0 <sleep>
  while(ticks - ticks0 < n){
80105f72:	a1 c0 53 11 80       	mov    0x801153c0,%eax
80105f77:	83 c4 10             	add    $0x10,%esp
80105f7a:	29 d8                	sub    %ebx,%eax
80105f7c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105f7f:	73 2f                	jae    80105fb0 <sys_sleep+0x90>
    if(myproc()->killed){
80105f81:	e8 4a da ff ff       	call   801039d0 <myproc>
80105f86:	8b 40 24             	mov    0x24(%eax),%eax
80105f89:	85 c0                	test   %eax,%eax
80105f8b:	74 d3                	je     80105f60 <sys_sleep+0x40>
      release(&tickslock);
80105f8d:	83 ec 0c             	sub    $0xc,%esp
80105f90:	68 e0 53 11 80       	push   $0x801153e0
80105f95:	e8 66 ed ff ff       	call   80104d00 <release>
  }
  release(&tickslock);
  return 0;
}
80105f9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
80105f9d:	83 c4 10             	add    $0x10,%esp
80105fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fa5:	c9                   	leave  
80105fa6:	c3                   	ret    
80105fa7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105fae:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105fb0:	83 ec 0c             	sub    $0xc,%esp
80105fb3:	68 e0 53 11 80       	push   $0x801153e0
80105fb8:	e8 43 ed ff ff       	call   80104d00 <release>
  return 0;
80105fbd:	83 c4 10             	add    $0x10,%esp
80105fc0:	31 c0                	xor    %eax,%eax
}
80105fc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105fc5:	c9                   	leave  
80105fc6:	c3                   	ret    
    return -1;
80105fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fcc:	eb f4                	jmp    80105fc2 <sys_sleep+0xa2>
80105fce:	66 90                	xchg   %ax,%ax

80105fd0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105fd0:	55                   	push   %ebp
80105fd1:	89 e5                	mov    %esp,%ebp
80105fd3:	53                   	push   %ebx
80105fd4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105fd7:	68 e0 53 11 80       	push   $0x801153e0
80105fdc:	e8 7f ed ff ff       	call   80104d60 <acquire>
  xticks = ticks;
80105fe1:	8b 1d c0 53 11 80    	mov    0x801153c0,%ebx
  release(&tickslock);
80105fe7:	c7 04 24 e0 53 11 80 	movl   $0x801153e0,(%esp)
80105fee:	e8 0d ed ff ff       	call   80104d00 <release>
  return xticks;
}
80105ff3:	89 d8                	mov    %ebx,%eax
80105ff5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105ff8:	c9                   	leave  
80105ff9:	c3                   	ret    
80105ffa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106000 <sys_yield>:

int
sys_yield(void)
{
80106000:	55                   	push   %ebp
80106001:	89 e5                	mov    %esp,%ebp
80106003:	83 ec 08             	sub    $0x8,%esp
  yield();
80106006:	e8 55 e3 ff ff       	call   80104360 <yield>
  return 0;
}
8010600b:	31 c0                	xor    %eax,%eax
8010600d:	c9                   	leave  
8010600e:	c3                   	ret    
8010600f:	90                   	nop

80106010 <sys_getLevel>:

int
sys_getLevel(void)
{
  return getLevel();
80106010:	e9 8b e7 ff ff       	jmp    801047a0 <getLevel>
80106015:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010601c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106020 <sys_setPriority>:
}

int
sys_setPriority(void)
{
80106020:	55                   	push   %ebp
80106021:	89 e5                	mov    %esp,%ebp
80106023:	83 ec 20             	sub    $0x20,%esp
  int pid;
  int priority;

  if(argint(0, &pid) < 0 || argint(1, &priority) < 0)
80106026:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106029:	50                   	push   %eax
8010602a:	6a 00                	push   $0x0
8010602c:	e8 af f0 ff ff       	call   801050e0 <argint>
80106031:	83 c4 10             	add    $0x10,%esp
80106034:	85 c0                	test   %eax,%eax
80106036:	78 30                	js     80106068 <sys_setPriority+0x48>
80106038:	83 ec 08             	sub    $0x8,%esp
8010603b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010603e:	50                   	push   %eax
8010603f:	6a 01                	push   $0x1
80106041:	e8 9a f0 ff ff       	call   801050e0 <argint>
80106046:	83 c4 10             	add    $0x10,%esp
80106049:	85 c0                	test   %eax,%eax
8010604b:	78 1b                	js     80106068 <sys_setPriority+0x48>
    return -1;
  setPriority(pid, priority);
8010604d:	83 ec 08             	sub    $0x8,%esp
80106050:	ff 75 f4             	push   -0xc(%ebp)
80106053:	ff 75 f0             	push   -0x10(%ebp)
80106056:	e8 75 e7 ff ff       	call   801047d0 <setPriority>
  return 0;
8010605b:	83 c4 10             	add    $0x10,%esp
8010605e:	31 c0                	xor    %eax,%eax
}
80106060:	c9                   	leave  
80106061:	c3                   	ret    
80106062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106068:	c9                   	leave  
    return -1;
80106069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010606e:	c3                   	ret    
8010606f:	90                   	nop

80106070 <sys_schedulerLock>:

int
sys_schedulerLock(void)
{
80106070:	55                   	push   %ebp
80106071:	89 e5                	mov    %esp,%ebp
80106073:	53                   	push   %ebx
  int password;

  if(argint(0, &password))
80106074:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80106077:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &password))
8010607a:	50                   	push   %eax
8010607b:	6a 00                	push   $0x0
8010607d:	e8 5e f0 ff ff       	call   801050e0 <argint>
80106082:	83 c4 10             	add    $0x10,%esp
80106085:	85 c0                	test   %eax,%eax
80106087:	75 17                	jne    801060a0 <sys_schedulerLock+0x30>
    return -1;
  schedulerLock(password);
80106089:	83 ec 0c             	sub    $0xc,%esp
8010608c:	ff 75 f4             	push   -0xc(%ebp)
8010608f:	89 c3                	mov    %eax,%ebx
80106091:	e8 ba e7 ff ff       	call   80104850 <schedulerLock>
  return 0;
80106096:	83 c4 10             	add    $0x10,%esp
}
80106099:	89 d8                	mov    %ebx,%eax
8010609b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010609e:	c9                   	leave  
8010609f:	c3                   	ret    
    return -1;
801060a0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801060a5:	eb f2                	jmp    80106099 <sys_schedulerLock+0x29>
801060a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801060ae:	66 90                	xchg   %ax,%ax

801060b0 <sys_schedulerUnlock>:

int
sys_schedulerUnlock(void)
{
801060b0:	55                   	push   %ebp
801060b1:	89 e5                	mov    %esp,%ebp
801060b3:	53                   	push   %ebx
  int password;

  if(argint(0, &password))
801060b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
801060b7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &password))
801060ba:	50                   	push   %eax
801060bb:	6a 00                	push   $0x0
801060bd:	e8 1e f0 ff ff       	call   801050e0 <argint>
801060c2:	83 c4 10             	add    $0x10,%esp
801060c5:	85 c0                	test   %eax,%eax
801060c7:	75 17                	jne    801060e0 <sys_schedulerUnlock+0x30>
    return -1;
  schedulerUnlock(password);
801060c9:	83 ec 0c             	sub    $0xc,%esp
801060cc:	ff 75 f4             	push   -0xc(%ebp)
801060cf:	89 c3                	mov    %eax,%ebx
801060d1:	e8 2a e8 ff ff       	call   80104900 <schedulerUnlock>
  return 0;
801060d6:	83 c4 10             	add    $0x10,%esp
801060d9:	89 d8                	mov    %ebx,%eax
801060db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801060de:	c9                   	leave  
801060df:	c3                   	ret    
    return -1;
801060e0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801060e5:	eb f2                	jmp    801060d9 <sys_schedulerUnlock+0x29>

801060e7 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801060e7:	1e                   	push   %ds
  pushl %es
801060e8:	06                   	push   %es
  pushl %fs
801060e9:	0f a0                	push   %fs
  pushl %gs
801060eb:	0f a8                	push   %gs
  pushal
801060ed:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801060ee:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801060f2:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801060f4:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801060f6:	54                   	push   %esp
  call trap
801060f7:	e8 14 01 00 00       	call   80106210 <trap>
  addl $4, %esp
801060fc:	83 c4 04             	add    $0x4,%esp

801060ff <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801060ff:	61                   	popa   
  popl %gs
80106100:	0f a9                	pop    %gs
  popl %fs
80106102:	0f a1                	pop    %fs
  popl %es
80106104:	07                   	pop    %es
  popl %ds
80106105:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106106:	83 c4 08             	add    $0x8,%esp
  iret
80106109:	cf                   	iret   
8010610a:	66 90                	xchg   %ax,%ax
8010610c:	66 90                	xchg   %ax,%ax
8010610e:	66 90                	xchg   %ax,%ax

80106110 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void) // initialize trap vector
{
80106110:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80106111:	31 c0                	xor    %eax,%eax
{
80106113:	89 e5                	mov    %esp,%ebp
80106115:	83 ec 08             	sub    $0x8,%esp
80106118:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010611f:	90                   	nop
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106120:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
80106127:	c7 04 c5 22 54 11 80 	movl   $0x8e000008,-0x7feeabde(,%eax,8)
8010612e:	08 00 00 8e 
80106132:	66 89 14 c5 20 54 11 	mov    %dx,-0x7feeabe0(,%eax,8)
80106139:	80 
8010613a:	c1 ea 10             	shr    $0x10,%edx
8010613d:	66 89 14 c5 26 54 11 	mov    %dx,-0x7feeabda(,%eax,8)
80106144:	80 
  for(i = 0; i < 256; i++)
80106145:	83 c0 01             	add    $0x1,%eax
80106148:	3d 00 01 00 00       	cmp    $0x100,%eax
8010614d:	75 d1                	jne    80106120 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010614f:	a1 08 b1 10 80       	mov    0x8010b108,%eax
  SETGATE(idt[T_SAMPLE128], 1, SEG_KCODE<<3, vectors[T_SAMPLE128], DPL_USER);
  SETGATE(idt[T_SLOCK], 1, SEG_KCODE<<3, vectors[T_SLOCK], DPL_USER); // schedulerLock interrupt
  SETGATE(idt[T_SUNLOCK], 1, SEG_KCODE<<3, vectors[T_SUNLOCK], DPL_USER); // schedulerUnlock interrupt

  initlock(&tickslock, "time");
80106154:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106157:	c7 05 22 56 11 80 08 	movl   $0xef000008,0x80115622
8010615e:	00 00 ef 
  initlock(&tickslock, "time");
80106161:	68 51 87 10 80       	push   $0x80108751
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106166:	66 a3 20 56 11 80    	mov    %ax,0x80115620
8010616c:	c1 e8 10             	shr    $0x10,%eax
8010616f:	66 a3 26 56 11 80    	mov    %ax,0x80115626
  SETGATE(idt[T_SAMPLE128], 1, SEG_KCODE<<3, vectors[T_SAMPLE128], DPL_USER);
80106175:	a1 08 b2 10 80       	mov    0x8010b208,%eax
  initlock(&tickslock, "time");
8010617a:	68 e0 53 11 80       	push   $0x801153e0
  SETGATE(idt[T_SAMPLE128], 1, SEG_KCODE<<3, vectors[T_SAMPLE128], DPL_USER);
8010617f:	66 a3 20 58 11 80    	mov    %ax,0x80115820
80106185:	c1 e8 10             	shr    $0x10,%eax
80106188:	66 a3 26 58 11 80    	mov    %ax,0x80115826
  SETGATE(idt[T_SLOCK], 1, SEG_KCODE<<3, vectors[T_SLOCK], DPL_USER); // schedulerLock interrupt
8010618e:	a1 0c b2 10 80       	mov    0x8010b20c,%eax
  SETGATE(idt[T_SAMPLE128], 1, SEG_KCODE<<3, vectors[T_SAMPLE128], DPL_USER);
80106193:	c7 05 22 58 11 80 08 	movl   $0xef000008,0x80115822
8010619a:	00 00 ef 
  SETGATE(idt[T_SLOCK], 1, SEG_KCODE<<3, vectors[T_SLOCK], DPL_USER); // schedulerLock interrupt
8010619d:	66 a3 28 58 11 80    	mov    %ax,0x80115828
801061a3:	c1 e8 10             	shr    $0x10,%eax
801061a6:	66 a3 2e 58 11 80    	mov    %ax,0x8011582e
  SETGATE(idt[T_SUNLOCK], 1, SEG_KCODE<<3, vectors[T_SUNLOCK], DPL_USER); // schedulerUnlock interrupt
801061ac:	a1 10 b2 10 80       	mov    0x8010b210,%eax
  SETGATE(idt[T_SLOCK], 1, SEG_KCODE<<3, vectors[T_SLOCK], DPL_USER); // schedulerLock interrupt
801061b1:	c7 05 2a 58 11 80 08 	movl   $0xef000008,0x8011582a
801061b8:	00 00 ef 
  SETGATE(idt[T_SUNLOCK], 1, SEG_KCODE<<3, vectors[T_SUNLOCK], DPL_USER); // schedulerUnlock interrupt
801061bb:	66 a3 30 58 11 80    	mov    %ax,0x80115830
801061c1:	c1 e8 10             	shr    $0x10,%eax
801061c4:	c7 05 32 58 11 80 08 	movl   $0xef000008,0x80115832
801061cb:	00 00 ef 
801061ce:	66 a3 36 58 11 80    	mov    %ax,0x80115836
  initlock(&tickslock, "time");
801061d4:	e8 b7 e9 ff ff       	call   80104b90 <initlock>
}
801061d9:	83 c4 10             	add    $0x10,%esp
801061dc:	c9                   	leave  
801061dd:	c3                   	ret    
801061de:	66 90                	xchg   %ax,%ax

801061e0 <idtinit>:

void
idtinit(void)
{
801061e0:	55                   	push   %ebp
  pd[0] = size-1;
801061e1:	b8 ff 07 00 00       	mov    $0x7ff,%eax
801061e6:	89 e5                	mov    %esp,%ebp
801061e8:	83 ec 10             	sub    $0x10,%esp
801061eb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801061ef:	b8 20 54 11 80       	mov    $0x80115420,%eax
801061f4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801061f8:	c1 e8 10             	shr    $0x10,%eax
801061fb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801061ff:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106202:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80106205:	c9                   	leave  
80106206:	c3                   	ret    
80106207:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010620e:	66 90                	xchg   %ax,%ax

80106210 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106210:	55                   	push   %ebp
80106211:	89 e5                	mov    %esp,%ebp
80106213:	57                   	push   %edi
80106214:	56                   	push   %esi
80106215:	53                   	push   %ebx
80106216:	83 ec 1c             	sub    $0x1c,%esp
80106219:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010621c:	8b 43 30             	mov    0x30(%ebx),%eax
8010621f:	83 f8 40             	cmp    $0x40,%eax
80106222:	0f 84 f8 01 00 00    	je     80106420 <trap+0x210>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80106228:	83 f8 3f             	cmp    $0x3f,%eax
8010622b:	0f 87 9f 00 00 00    	ja     801062d0 <trap+0xc0>
80106231:	83 f8 1f             	cmp    $0x1f,%eax
80106234:	0f 86 e6 00 00 00    	jbe    80106320 <trap+0x110>
8010623a:	83 e8 20             	sub    $0x20,%eax
8010623d:	83 f8 1f             	cmp    $0x1f,%eax
80106240:	0f 87 da 00 00 00    	ja     80106320 <trap+0x110>
80106246:	ff 24 85 14 88 10 80 	jmp    *-0x7fef77ec(,%eax,4)
8010624d:	8d 76 00             	lea    0x0(%esi),%esi
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){ // cpu id가 0인게 무슨 의미지?? 첫번째 cpu일때를 의미하는 듯. 근데 어차피 우린 cpu한개로 만드니까.. 항상 0!
80106250:	e8 5b d7 ff ff       	call   801039b0 <cpuid>
80106255:	85 c0                	test   %eax,%eax
80106257:	0f 84 e3 02 00 00    	je     80106540 <trap+0x330>
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
8010625d:	e8 ae c6 ff ff       	call   80102910 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106262:	e8 69 d7 ff ff       	call   801039d0 <myproc>
80106267:	85 c0                	test   %eax,%eax
80106269:	74 1d                	je     80106288 <trap+0x78>
8010626b:	e8 60 d7 ff ff       	call   801039d0 <myproc>
80106270:	8b 78 24             	mov    0x24(%eax),%edi
80106273:	85 ff                	test   %edi,%edi
80106275:	74 11                	je     80106288 <trap+0x78>
80106277:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010627b:	83 e0 03             	and    $0x3,%eax
8010627e:	66 83 f8 03          	cmp    $0x3,%ax
80106282:	0f 84 28 02 00 00    	je     801064b0 <trap+0x2a0>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106288:	e8 43 d7 ff ff       	call   801039d0 <myproc>
8010628d:	85 c0                	test   %eax,%eax
8010628f:	74 0f                	je     801062a0 <trap+0x90>
80106291:	e8 3a d7 ff ff       	call   801039d0 <myproc>
80106296:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010629a:	0f 84 f8 00 00 00    	je     80106398 <trap+0x188>
      if(myproc()->locked == 0)
        yield();
  }

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801062a0:	e8 2b d7 ff ff       	call   801039d0 <myproc>
801062a5:	85 c0                	test   %eax,%eax
801062a7:	74 1d                	je     801062c6 <trap+0xb6>
801062a9:	e8 22 d7 ff ff       	call   801039d0 <myproc>
801062ae:	8b 40 24             	mov    0x24(%eax),%eax
801062b1:	85 c0                	test   %eax,%eax
801062b3:	74 11                	je     801062c6 <trap+0xb6>
801062b5:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801062b9:	83 e0 03             	and    $0x3,%eax
801062bc:	66 83 f8 03          	cmp    $0x3,%ax
801062c0:	0f 84 87 01 00 00    	je     8010644d <trap+0x23d>
    exit();

}
801062c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062c9:	5b                   	pop    %ebx
801062ca:	5e                   	pop    %esi
801062cb:	5f                   	pop    %edi
801062cc:	5d                   	pop    %ebp
801062cd:	c3                   	ret    
801062ce:	66 90                	xchg   %ax,%ax
  switch(tf->trapno){
801062d0:	3d 81 00 00 00       	cmp    $0x81,%eax
801062d5:	0f 84 b5 01 00 00    	je     80106490 <trap+0x280>
801062db:	3d 82 00 00 00       	cmp    $0x82,%eax
801062e0:	75 1a                	jne    801062fc <trap+0xec>
    schedulerUnlock(PASSWORD);
801062e2:	83 ec 0c             	sub    $0xc,%esp
801062e5:	68 10 ab 58 78       	push   $0x7858ab10
801062ea:	e8 11 e6 ff ff       	call   80104900 <schedulerUnlock>
    lapiceoi();
801062ef:	e8 1c c6 ff ff       	call   80102910 <lapiceoi>
    break;
801062f4:	83 c4 10             	add    $0x10,%esp
801062f7:	e9 66 ff ff ff       	jmp    80106262 <trap+0x52>
  switch(tf->trapno){
801062fc:	3d 80 00 00 00       	cmp    $0x80,%eax
80106301:	75 1d                	jne    80106320 <trap+0x110>
    cprintf("user interrupt 128 called!\n");
80106303:	83 ec 0c             	sub    $0xc,%esp
80106306:	68 56 87 10 80       	push   $0x80108756
8010630b:	e8 90 a3 ff ff       	call   801006a0 <cprintf>
    lapiceoi();
80106310:	e8 fb c5 ff ff       	call   80102910 <lapiceoi>
    break;
80106315:	83 c4 10             	add    $0x10,%esp
80106318:	e9 45 ff ff ff       	jmp    80106262 <trap+0x52>
8010631d:	8d 76 00             	lea    0x0(%esi),%esi
    if(myproc() == 0 || (tf->cs&3) == 0){
80106320:	e8 ab d6 ff ff       	call   801039d0 <myproc>
80106325:	8b 7b 38             	mov    0x38(%ebx),%edi
80106328:	85 c0                	test   %eax,%eax
8010632a:	0f 84 b1 02 00 00    	je     801065e1 <trap+0x3d1>
80106330:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80106334:	0f 84 a7 02 00 00    	je     801065e1 <trap+0x3d1>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010633a:	0f 20 d1             	mov    %cr2,%ecx
8010633d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106340:	e8 6b d6 ff ff       	call   801039b0 <cpuid>
80106345:	8b 73 30             	mov    0x30(%ebx),%esi
80106348:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010634b:	8b 43 34             	mov    0x34(%ebx),%eax
8010634e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            myproc()->pid, myproc()->name, tf->trapno,
80106351:	e8 7a d6 ff ff       	call   801039d0 <myproc>
80106356:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106359:	e8 72 d6 ff ff       	call   801039d0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010635e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80106361:	8b 55 dc             	mov    -0x24(%ebp),%edx
80106364:	51                   	push   %ecx
80106365:	57                   	push   %edi
80106366:	52                   	push   %edx
80106367:	ff 75 e4             	push   -0x1c(%ebp)
8010636a:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
8010636b:	8b 75 e0             	mov    -0x20(%ebp),%esi
8010636e:	83 c6 6c             	add    $0x6c,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106371:	56                   	push   %esi
80106372:	ff 70 10             	push   0x10(%eax)
80106375:	68 d0 87 10 80       	push   $0x801087d0
8010637a:	e8 21 a3 ff ff       	call   801006a0 <cprintf>
    myproc()->killed = 1;
8010637f:	83 c4 20             	add    $0x20,%esp
80106382:	e8 49 d6 ff ff       	call   801039d0 <myproc>
80106387:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010638e:	e9 cf fe ff ff       	jmp    80106262 <trap+0x52>
80106393:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106397:	90                   	nop
  if(myproc() && myproc()->state == RUNNING &&
80106398:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010639c:	0f 85 fe fe ff ff    	jne    801062a0 <trap+0x90>
      if(!(ticks % 100)){
801063a2:	69 05 c0 53 11 80 29 	imul   $0xc28f5c29,0x801153c0,%eax
801063a9:	5c 8f c2 
801063ac:	c1 c8 02             	ror    $0x2,%eax
801063af:	3d 28 5c 8f 02       	cmp    $0x28f5c28,%eax
801063b4:	0f 86 06 01 00 00    	jbe    801064c0 <trap+0x2b0>
     if(myproc()->locked == 0 &&
801063ba:	e8 11 d6 ff ff       	call   801039d0 <myproc>
801063bf:	8b 88 88 00 00 00    	mov    0x88(%eax),%ecx
801063c5:	85 c9                	test   %ecx,%ecx
801063c7:	0f 84 13 01 00 00    	je     801064e0 <trap+0x2d0>
      if(myproc()->locked == 0)
801063cd:	e8 fe d5 ff ff       	call   801039d0 <myproc>
801063d2:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
801063d8:	85 d2                	test   %edx,%edx
801063da:	0f 85 c0 fe ff ff    	jne    801062a0 <trap+0x90>
        yield();
801063e0:	e8 7b df ff ff       	call   80104360 <yield>
801063e5:	e9 b6 fe ff ff       	jmp    801062a0 <trap+0x90>
801063ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063f0:	8b 7b 38             	mov    0x38(%ebx),%edi
801063f3:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
801063f7:	e8 b4 d5 ff ff       	call   801039b0 <cpuid>
801063fc:	57                   	push   %edi
801063fd:	56                   	push   %esi
801063fe:	50                   	push   %eax
801063ff:	68 78 87 10 80       	push   $0x80108778
80106404:	e8 97 a2 ff ff       	call   801006a0 <cprintf>
    lapiceoi();
80106409:	e8 02 c5 ff ff       	call   80102910 <lapiceoi>
    break;
8010640e:	83 c4 10             	add    $0x10,%esp
80106411:	e9 4c fe ff ff       	jmp    80106262 <trap+0x52>
80106416:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010641d:	8d 76 00             	lea    0x0(%esi),%esi
    if(myproc()->killed)
80106420:	e8 ab d5 ff ff       	call   801039d0 <myproc>
80106425:	8b 40 24             	mov    0x24(%eax),%eax
80106428:	85 c0                	test   %eax,%eax
8010642a:	0f 85 00 01 00 00    	jne    80106530 <trap+0x320>
    myproc()->tf = tf;
80106430:	e8 9b d5 ff ff       	call   801039d0 <myproc>
80106435:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80106438:	e8 e3 ed ff ff       	call   80105220 <syscall>
    if(myproc()->killed)
8010643d:	e8 8e d5 ff ff       	call   801039d0 <myproc>
80106442:	8b 40 24             	mov    0x24(%eax),%eax
80106445:	85 c0                	test   %eax,%eax
80106447:	0f 84 79 fe ff ff    	je     801062c6 <trap+0xb6>
}
8010644d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106450:	5b                   	pop    %ebx
80106451:	5e                   	pop    %esi
80106452:	5f                   	pop    %edi
80106453:	5d                   	pop    %ebp
      exit();
80106454:	e9 87 dc ff ff       	jmp    801040e0 <exit>
80106459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kbdintr();
80106460:	e8 6b c3 ff ff       	call   801027d0 <kbdintr>
    lapiceoi();
80106465:	e8 a6 c4 ff ff       	call   80102910 <lapiceoi>
    break;
8010646a:	e9 f3 fd ff ff       	jmp    80106262 <trap+0x52>
8010646f:	90                   	nop
    uartintr();
80106470:	e8 0b 03 00 00       	call   80106780 <uartintr>
    lapiceoi();
80106475:	e8 96 c4 ff ff       	call   80102910 <lapiceoi>
    break;
8010647a:	e9 e3 fd ff ff       	jmp    80106262 <trap+0x52>
8010647f:	90                   	nop
    ideintr();
80106480:	e8 bb bd ff ff       	call   80102240 <ideintr>
80106485:	e9 d3 fd ff ff       	jmp    8010625d <trap+0x4d>
8010648a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    schedulerLock(PASSWORD);
80106490:	83 ec 0c             	sub    $0xc,%esp
80106493:	68 10 ab 58 78       	push   $0x7858ab10
80106498:	e8 b3 e3 ff ff       	call   80104850 <schedulerLock>
    lapiceoi();
8010649d:	e8 6e c4 ff ff       	call   80102910 <lapiceoi>
    break;
801064a2:	83 c4 10             	add    $0x10,%esp
801064a5:	e9 b8 fd ff ff       	jmp    80106262 <trap+0x52>
801064aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    exit();
801064b0:	e8 2b dc ff ff       	call   801040e0 <exit>
801064b5:	e9 ce fd ff ff       	jmp    80106288 <trap+0x78>
801064ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        if(myproc()->locked)
801064c0:	e8 0b d5 ff ff       	call   801039d0 <myproc>
801064c5:	8b b0 88 00 00 00    	mov    0x88(%eax),%esi
801064cb:	85 f6                	test   %esi,%esi
801064cd:	0f 85 b9 00 00 00    	jne    8010658c <trap+0x37c>
        priorityBoosting();
801064d3:	e8 38 e1 ff ff       	call   80104610 <priorityBoosting>
801064d8:	e9 dd fe ff ff       	jmp    801063ba <trap+0x1aa>
801064dd:	8d 76 00             	lea    0x0(%esi),%esi
        myproc()->tq == myproc()->lev * 2 + 4){ // 큐가 tq을 모두 소비한 경우
801064e0:	e8 eb d4 ff ff       	call   801039d0 <myproc>
801064e5:	8b b0 80 00 00 00    	mov    0x80(%eax),%esi
801064eb:	e8 e0 d4 ff ff       	call   801039d0 <myproc>
801064f0:	8b 40 7c             	mov    0x7c(%eax),%eax
801064f3:	8d 44 00 04          	lea    0x4(%eax,%eax,1),%eax
     if(myproc()->locked == 0 &&
801064f7:	39 c6                	cmp    %eax,%esi
801064f9:	0f 85 ce fe ff ff    	jne    801063cd <trap+0x1bd>
        if(myproc()->lev != 2)
801064ff:	e8 cc d4 ff ff       	call   801039d0 <myproc>
80106504:	83 78 7c 02          	cmpl   $0x2,0x7c(%eax)
80106508:	0f 84 a1 00 00 00    	je     801065af <trap+0x39f>
          myproc()->lev++;
8010650e:	e8 bd d4 ff ff       	call   801039d0 <myproc>
80106513:	83 40 7c 01          	addl   $0x1,0x7c(%eax)
        myproc()->tq = 0;
80106517:	e8 b4 d4 ff ff       	call   801039d0 <myproc>
8010651c:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80106523:	00 00 00 
80106526:	e9 a2 fe ff ff       	jmp    801063cd <trap+0x1bd>
8010652b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010652f:	90                   	nop
      exit();
80106530:	e8 ab db ff ff       	call   801040e0 <exit>
80106535:	e9 f6 fe ff ff       	jmp    80106430 <trap+0x220>
8010653a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      acquire(&tickslock);
80106540:	83 ec 0c             	sub    $0xc,%esp
80106543:	68 e0 53 11 80       	push   $0x801153e0
80106548:	e8 13 e8 ff ff       	call   80104d60 <acquire>
      ticks++;
8010654d:	83 05 c0 53 11 80 01 	addl   $0x1,0x801153c0
      if (myproc() && myproc()->state == RUNNING)
80106554:	e8 77 d4 ff ff       	call   801039d0 <myproc>
80106559:	83 c4 10             	add    $0x10,%esp
8010655c:	85 c0                	test   %eax,%eax
8010655e:	74 0b                	je     8010656b <trap+0x35b>
80106560:	e8 6b d4 ff ff       	call   801039d0 <myproc>
80106565:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80106569:	74 36                	je     801065a1 <trap+0x391>
      wakeup(&ticks);
8010656b:	83 ec 0c             	sub    $0xc,%esp
8010656e:	68 c0 53 11 80       	push   $0x801153c0
80106573:	e8 f8 de ff ff       	call   80104470 <wakeup>
      release(&tickslock);
80106578:	c7 04 24 e0 53 11 80 	movl   $0x801153e0,(%esp)
8010657f:	e8 7c e7 ff ff       	call   80104d00 <release>
80106584:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106587:	e9 d1 fc ff ff       	jmp    8010625d <trap+0x4d>
          schedulerUnlock(PASSWORD); 
8010658c:	83 ec 0c             	sub    $0xc,%esp
8010658f:	68 10 ab 58 78       	push   $0x7858ab10
80106594:	e8 67 e3 ff ff       	call   80104900 <schedulerUnlock>
80106599:	83 c4 10             	add    $0x10,%esp
8010659c:	e9 32 ff ff ff       	jmp    801064d3 <trap+0x2c3>
        myproc()->tq++; // 현재 프로세스의 time quantum 1 증가
801065a1:	e8 2a d4 ff ff       	call   801039d0 <myproc>
801065a6:	83 80 80 00 00 00 01 	addl   $0x1,0x80(%eax)
801065ad:	eb bc                	jmp    8010656b <trap+0x35b>
        else if(myproc()->lev == 2){
801065af:	e8 1c d4 ff ff       	call   801039d0 <myproc>
801065b4:	83 78 7c 02          	cmpl   $0x2,0x7c(%eax)
801065b8:	0f 85 59 ff ff ff    	jne    80106517 <trap+0x307>
          if(myproc()->priority > 0)
801065be:	e8 0d d4 ff ff       	call   801039d0 <myproc>
801065c3:	83 b8 84 00 00 00 00 	cmpl   $0x0,0x84(%eax)
801065ca:	0f 8e 47 ff ff ff    	jle    80106517 <trap+0x307>
            myproc()->priority--;
801065d0:	e8 fb d3 ff ff       	call   801039d0 <myproc>
801065d5:	83 a8 84 00 00 00 01 	subl   $0x1,0x84(%eax)
801065dc:	e9 36 ff ff ff       	jmp    80106517 <trap+0x307>
801065e1:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065e4:	e8 c7 d3 ff ff       	call   801039b0 <cpuid>
801065e9:	83 ec 0c             	sub    $0xc,%esp
801065ec:	56                   	push   %esi
801065ed:	57                   	push   %edi
801065ee:	50                   	push   %eax
801065ef:	ff 73 30             	push   0x30(%ebx)
801065f2:	68 9c 87 10 80       	push   $0x8010879c
801065f7:	e8 a4 a0 ff ff       	call   801006a0 <cprintf>
      panic("trap");
801065fc:	83 c4 14             	add    $0x14,%esp
801065ff:	68 72 87 10 80       	push   $0x80108772
80106604:	e8 77 9d ff ff       	call   80100380 <panic>
80106609:	66 90                	xchg   %ax,%ax
8010660b:	66 90                	xchg   %ax,%ax
8010660d:	66 90                	xchg   %ax,%ax
8010660f:	90                   	nop

80106610 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80106610:	a1 20 5c 11 80       	mov    0x80115c20,%eax
80106615:	85 c0                	test   %eax,%eax
80106617:	74 17                	je     80106630 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106619:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010661e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010661f:	a8 01                	test   $0x1,%al
80106621:	74 0d                	je     80106630 <uartgetc+0x20>
80106623:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106628:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80106629:	0f b6 c0             	movzbl %al,%eax
8010662c:	c3                   	ret    
8010662d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80106630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106635:	c3                   	ret    
80106636:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010663d:	8d 76 00             	lea    0x0(%esi),%esi

80106640 <uartinit>:
{
80106640:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106641:	31 c9                	xor    %ecx,%ecx
80106643:	89 c8                	mov    %ecx,%eax
80106645:	89 e5                	mov    %esp,%ebp
80106647:	57                   	push   %edi
80106648:	bf fa 03 00 00       	mov    $0x3fa,%edi
8010664d:	56                   	push   %esi
8010664e:	89 fa                	mov    %edi,%edx
80106650:	53                   	push   %ebx
80106651:	83 ec 1c             	sub    $0x1c,%esp
80106654:	ee                   	out    %al,(%dx)
80106655:	be fb 03 00 00       	mov    $0x3fb,%esi
8010665a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010665f:	89 f2                	mov    %esi,%edx
80106661:	ee                   	out    %al,(%dx)
80106662:	b8 0c 00 00 00       	mov    $0xc,%eax
80106667:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010666c:	ee                   	out    %al,(%dx)
8010666d:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80106672:	89 c8                	mov    %ecx,%eax
80106674:	89 da                	mov    %ebx,%edx
80106676:	ee                   	out    %al,(%dx)
80106677:	b8 03 00 00 00       	mov    $0x3,%eax
8010667c:	89 f2                	mov    %esi,%edx
8010667e:	ee                   	out    %al,(%dx)
8010667f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80106684:	89 c8                	mov    %ecx,%eax
80106686:	ee                   	out    %al,(%dx)
80106687:	b8 01 00 00 00       	mov    $0x1,%eax
8010668c:	89 da                	mov    %ebx,%edx
8010668e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010668f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106694:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80106695:	3c ff                	cmp    $0xff,%al
80106697:	74 78                	je     80106711 <uartinit+0xd1>
  uart = 1;
80106699:	c7 05 20 5c 11 80 01 	movl   $0x1,0x80115c20
801066a0:	00 00 00 
801066a3:	89 fa                	mov    %edi,%edx
801066a5:	ec                   	in     (%dx),%al
801066a6:	ba f8 03 00 00       	mov    $0x3f8,%edx
801066ab:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801066ac:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
801066af:	bf 94 88 10 80       	mov    $0x80108894,%edi
801066b4:	be fd 03 00 00       	mov    $0x3fd,%esi
  ioapicenable(IRQ_COM1, 0);
801066b9:	6a 00                	push   $0x0
801066bb:	6a 04                	push   $0x4
801066bd:	e8 be bd ff ff       	call   80102480 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801066c2:	c6 45 e7 78          	movb   $0x78,-0x19(%ebp)
  ioapicenable(IRQ_COM1, 0);
801066c6:	83 c4 10             	add    $0x10,%esp
801066c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(!uart)
801066d0:	a1 20 5c 11 80       	mov    0x80115c20,%eax
801066d5:	bb 80 00 00 00       	mov    $0x80,%ebx
801066da:	85 c0                	test   %eax,%eax
801066dc:	75 14                	jne    801066f2 <uartinit+0xb2>
801066de:	eb 23                	jmp    80106703 <uartinit+0xc3>
    microdelay(10);
801066e0:	83 ec 0c             	sub    $0xc,%esp
801066e3:	6a 0a                	push   $0xa
801066e5:	e8 46 c2 ff ff       	call   80102930 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801066ea:	83 c4 10             	add    $0x10,%esp
801066ed:	83 eb 01             	sub    $0x1,%ebx
801066f0:	74 07                	je     801066f9 <uartinit+0xb9>
801066f2:	89 f2                	mov    %esi,%edx
801066f4:	ec                   	in     (%dx),%al
801066f5:	a8 20                	test   $0x20,%al
801066f7:	74 e7                	je     801066e0 <uartinit+0xa0>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066f9:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801066fd:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106702:	ee                   	out    %al,(%dx)
  for(p="xv6...\n"; *p; p++)
80106703:	0f b6 47 01          	movzbl 0x1(%edi),%eax
80106707:	83 c7 01             	add    $0x1,%edi
8010670a:	88 45 e7             	mov    %al,-0x19(%ebp)
8010670d:	84 c0                	test   %al,%al
8010670f:	75 bf                	jne    801066d0 <uartinit+0x90>
}
80106711:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106714:	5b                   	pop    %ebx
80106715:	5e                   	pop    %esi
80106716:	5f                   	pop    %edi
80106717:	5d                   	pop    %ebp
80106718:	c3                   	ret    
80106719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106720 <uartputc>:
  if(!uart)
80106720:	a1 20 5c 11 80       	mov    0x80115c20,%eax
80106725:	85 c0                	test   %eax,%eax
80106727:	74 47                	je     80106770 <uartputc+0x50>
{
80106729:	55                   	push   %ebp
8010672a:	89 e5                	mov    %esp,%ebp
8010672c:	56                   	push   %esi
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010672d:	be fd 03 00 00       	mov    $0x3fd,%esi
80106732:	53                   	push   %ebx
80106733:	bb 80 00 00 00       	mov    $0x80,%ebx
80106738:	eb 18                	jmp    80106752 <uartputc+0x32>
8010673a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    microdelay(10);
80106740:	83 ec 0c             	sub    $0xc,%esp
80106743:	6a 0a                	push   $0xa
80106745:	e8 e6 c1 ff ff       	call   80102930 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010674a:	83 c4 10             	add    $0x10,%esp
8010674d:	83 eb 01             	sub    $0x1,%ebx
80106750:	74 07                	je     80106759 <uartputc+0x39>
80106752:	89 f2                	mov    %esi,%edx
80106754:	ec                   	in     (%dx),%al
80106755:	a8 20                	test   $0x20,%al
80106757:	74 e7                	je     80106740 <uartputc+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106759:	8b 45 08             	mov    0x8(%ebp),%eax
8010675c:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106761:	ee                   	out    %al,(%dx)
}
80106762:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106765:	5b                   	pop    %ebx
80106766:	5e                   	pop    %esi
80106767:	5d                   	pop    %ebp
80106768:	c3                   	ret    
80106769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106770:	c3                   	ret    
80106771:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106778:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010677f:	90                   	nop

80106780 <uartintr>:

void
uartintr(void)
{
80106780:	55                   	push   %ebp
80106781:	89 e5                	mov    %esp,%ebp
80106783:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106786:	68 10 66 10 80       	push   $0x80106610
8010678b:	e8 f0 a0 ff ff       	call   80100880 <consoleintr>
}
80106790:	83 c4 10             	add    $0x10,%esp
80106793:	c9                   	leave  
80106794:	c3                   	ret    

80106795 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $0
80106797:	6a 00                	push   $0x0
  jmp alltraps
80106799:	e9 49 f9 ff ff       	jmp    801060e7 <alltraps>

8010679e <vector1>:
.globl vector1
vector1:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $1
801067a0:	6a 01                	push   $0x1
  jmp alltraps
801067a2:	e9 40 f9 ff ff       	jmp    801060e7 <alltraps>

801067a7 <vector2>:
.globl vector2
vector2:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $2
801067a9:	6a 02                	push   $0x2
  jmp alltraps
801067ab:	e9 37 f9 ff ff       	jmp    801060e7 <alltraps>

801067b0 <vector3>:
.globl vector3
vector3:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $3
801067b2:	6a 03                	push   $0x3
  jmp alltraps
801067b4:	e9 2e f9 ff ff       	jmp    801060e7 <alltraps>

801067b9 <vector4>:
.globl vector4
vector4:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $4
801067bb:	6a 04                	push   $0x4
  jmp alltraps
801067bd:	e9 25 f9 ff ff       	jmp    801060e7 <alltraps>

801067c2 <vector5>:
.globl vector5
vector5:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $5
801067c4:	6a 05                	push   $0x5
  jmp alltraps
801067c6:	e9 1c f9 ff ff       	jmp    801060e7 <alltraps>

801067cb <vector6>:
.globl vector6
vector6:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $6
801067cd:	6a 06                	push   $0x6
  jmp alltraps
801067cf:	e9 13 f9 ff ff       	jmp    801060e7 <alltraps>

801067d4 <vector7>:
.globl vector7
vector7:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $7
801067d6:	6a 07                	push   $0x7
  jmp alltraps
801067d8:	e9 0a f9 ff ff       	jmp    801060e7 <alltraps>

801067dd <vector8>:
.globl vector8
vector8:
  pushl $8
801067dd:	6a 08                	push   $0x8
  jmp alltraps
801067df:	e9 03 f9 ff ff       	jmp    801060e7 <alltraps>

801067e4 <vector9>:
.globl vector9
vector9:
  pushl $0
801067e4:	6a 00                	push   $0x0
  pushl $9
801067e6:	6a 09                	push   $0x9
  jmp alltraps
801067e8:	e9 fa f8 ff ff       	jmp    801060e7 <alltraps>

801067ed <vector10>:
.globl vector10
vector10:
  pushl $10
801067ed:	6a 0a                	push   $0xa
  jmp alltraps
801067ef:	e9 f3 f8 ff ff       	jmp    801060e7 <alltraps>

801067f4 <vector11>:
.globl vector11
vector11:
  pushl $11
801067f4:	6a 0b                	push   $0xb
  jmp alltraps
801067f6:	e9 ec f8 ff ff       	jmp    801060e7 <alltraps>

801067fb <vector12>:
.globl vector12
vector12:
  pushl $12
801067fb:	6a 0c                	push   $0xc
  jmp alltraps
801067fd:	e9 e5 f8 ff ff       	jmp    801060e7 <alltraps>

80106802 <vector13>:
.globl vector13
vector13:
  pushl $13
80106802:	6a 0d                	push   $0xd
  jmp alltraps
80106804:	e9 de f8 ff ff       	jmp    801060e7 <alltraps>

80106809 <vector14>:
.globl vector14
vector14:
  pushl $14
80106809:	6a 0e                	push   $0xe
  jmp alltraps
8010680b:	e9 d7 f8 ff ff       	jmp    801060e7 <alltraps>

80106810 <vector15>:
.globl vector15
vector15:
  pushl $0
80106810:	6a 00                	push   $0x0
  pushl $15
80106812:	6a 0f                	push   $0xf
  jmp alltraps
80106814:	e9 ce f8 ff ff       	jmp    801060e7 <alltraps>

80106819 <vector16>:
.globl vector16
vector16:
  pushl $0
80106819:	6a 00                	push   $0x0
  pushl $16
8010681b:	6a 10                	push   $0x10
  jmp alltraps
8010681d:	e9 c5 f8 ff ff       	jmp    801060e7 <alltraps>

80106822 <vector17>:
.globl vector17
vector17:
  pushl $17
80106822:	6a 11                	push   $0x11
  jmp alltraps
80106824:	e9 be f8 ff ff       	jmp    801060e7 <alltraps>

80106829 <vector18>:
.globl vector18
vector18:
  pushl $0
80106829:	6a 00                	push   $0x0
  pushl $18
8010682b:	6a 12                	push   $0x12
  jmp alltraps
8010682d:	e9 b5 f8 ff ff       	jmp    801060e7 <alltraps>

80106832 <vector19>:
.globl vector19
vector19:
  pushl $0
80106832:	6a 00                	push   $0x0
  pushl $19
80106834:	6a 13                	push   $0x13
  jmp alltraps
80106836:	e9 ac f8 ff ff       	jmp    801060e7 <alltraps>

8010683b <vector20>:
.globl vector20
vector20:
  pushl $0
8010683b:	6a 00                	push   $0x0
  pushl $20
8010683d:	6a 14                	push   $0x14
  jmp alltraps
8010683f:	e9 a3 f8 ff ff       	jmp    801060e7 <alltraps>

80106844 <vector21>:
.globl vector21
vector21:
  pushl $0
80106844:	6a 00                	push   $0x0
  pushl $21
80106846:	6a 15                	push   $0x15
  jmp alltraps
80106848:	e9 9a f8 ff ff       	jmp    801060e7 <alltraps>

8010684d <vector22>:
.globl vector22
vector22:
  pushl $0
8010684d:	6a 00                	push   $0x0
  pushl $22
8010684f:	6a 16                	push   $0x16
  jmp alltraps
80106851:	e9 91 f8 ff ff       	jmp    801060e7 <alltraps>

80106856 <vector23>:
.globl vector23
vector23:
  pushl $0
80106856:	6a 00                	push   $0x0
  pushl $23
80106858:	6a 17                	push   $0x17
  jmp alltraps
8010685a:	e9 88 f8 ff ff       	jmp    801060e7 <alltraps>

8010685f <vector24>:
.globl vector24
vector24:
  pushl $0
8010685f:	6a 00                	push   $0x0
  pushl $24
80106861:	6a 18                	push   $0x18
  jmp alltraps
80106863:	e9 7f f8 ff ff       	jmp    801060e7 <alltraps>

80106868 <vector25>:
.globl vector25
vector25:
  pushl $0
80106868:	6a 00                	push   $0x0
  pushl $25
8010686a:	6a 19                	push   $0x19
  jmp alltraps
8010686c:	e9 76 f8 ff ff       	jmp    801060e7 <alltraps>

80106871 <vector26>:
.globl vector26
vector26:
  pushl $0
80106871:	6a 00                	push   $0x0
  pushl $26
80106873:	6a 1a                	push   $0x1a
  jmp alltraps
80106875:	e9 6d f8 ff ff       	jmp    801060e7 <alltraps>

8010687a <vector27>:
.globl vector27
vector27:
  pushl $0
8010687a:	6a 00                	push   $0x0
  pushl $27
8010687c:	6a 1b                	push   $0x1b
  jmp alltraps
8010687e:	e9 64 f8 ff ff       	jmp    801060e7 <alltraps>

80106883 <vector28>:
.globl vector28
vector28:
  pushl $0
80106883:	6a 00                	push   $0x0
  pushl $28
80106885:	6a 1c                	push   $0x1c
  jmp alltraps
80106887:	e9 5b f8 ff ff       	jmp    801060e7 <alltraps>

8010688c <vector29>:
.globl vector29
vector29:
  pushl $0
8010688c:	6a 00                	push   $0x0
  pushl $29
8010688e:	6a 1d                	push   $0x1d
  jmp alltraps
80106890:	e9 52 f8 ff ff       	jmp    801060e7 <alltraps>

80106895 <vector30>:
.globl vector30
vector30:
  pushl $0
80106895:	6a 00                	push   $0x0
  pushl $30
80106897:	6a 1e                	push   $0x1e
  jmp alltraps
80106899:	e9 49 f8 ff ff       	jmp    801060e7 <alltraps>

8010689e <vector31>:
.globl vector31
vector31:
  pushl $0
8010689e:	6a 00                	push   $0x0
  pushl $31
801068a0:	6a 1f                	push   $0x1f
  jmp alltraps
801068a2:	e9 40 f8 ff ff       	jmp    801060e7 <alltraps>

801068a7 <vector32>:
.globl vector32
vector32:
  pushl $0
801068a7:	6a 00                	push   $0x0
  pushl $32
801068a9:	6a 20                	push   $0x20
  jmp alltraps
801068ab:	e9 37 f8 ff ff       	jmp    801060e7 <alltraps>

801068b0 <vector33>:
.globl vector33
vector33:
  pushl $0
801068b0:	6a 00                	push   $0x0
  pushl $33
801068b2:	6a 21                	push   $0x21
  jmp alltraps
801068b4:	e9 2e f8 ff ff       	jmp    801060e7 <alltraps>

801068b9 <vector34>:
.globl vector34
vector34:
  pushl $0
801068b9:	6a 00                	push   $0x0
  pushl $34
801068bb:	6a 22                	push   $0x22
  jmp alltraps
801068bd:	e9 25 f8 ff ff       	jmp    801060e7 <alltraps>

801068c2 <vector35>:
.globl vector35
vector35:
  pushl $0
801068c2:	6a 00                	push   $0x0
  pushl $35
801068c4:	6a 23                	push   $0x23
  jmp alltraps
801068c6:	e9 1c f8 ff ff       	jmp    801060e7 <alltraps>

801068cb <vector36>:
.globl vector36
vector36:
  pushl $0
801068cb:	6a 00                	push   $0x0
  pushl $36
801068cd:	6a 24                	push   $0x24
  jmp alltraps
801068cf:	e9 13 f8 ff ff       	jmp    801060e7 <alltraps>

801068d4 <vector37>:
.globl vector37
vector37:
  pushl $0
801068d4:	6a 00                	push   $0x0
  pushl $37
801068d6:	6a 25                	push   $0x25
  jmp alltraps
801068d8:	e9 0a f8 ff ff       	jmp    801060e7 <alltraps>

801068dd <vector38>:
.globl vector38
vector38:
  pushl $0
801068dd:	6a 00                	push   $0x0
  pushl $38
801068df:	6a 26                	push   $0x26
  jmp alltraps
801068e1:	e9 01 f8 ff ff       	jmp    801060e7 <alltraps>

801068e6 <vector39>:
.globl vector39
vector39:
  pushl $0
801068e6:	6a 00                	push   $0x0
  pushl $39
801068e8:	6a 27                	push   $0x27
  jmp alltraps
801068ea:	e9 f8 f7 ff ff       	jmp    801060e7 <alltraps>

801068ef <vector40>:
.globl vector40
vector40:
  pushl $0
801068ef:	6a 00                	push   $0x0
  pushl $40
801068f1:	6a 28                	push   $0x28
  jmp alltraps
801068f3:	e9 ef f7 ff ff       	jmp    801060e7 <alltraps>

801068f8 <vector41>:
.globl vector41
vector41:
  pushl $0
801068f8:	6a 00                	push   $0x0
  pushl $41
801068fa:	6a 29                	push   $0x29
  jmp alltraps
801068fc:	e9 e6 f7 ff ff       	jmp    801060e7 <alltraps>

80106901 <vector42>:
.globl vector42
vector42:
  pushl $0
80106901:	6a 00                	push   $0x0
  pushl $42
80106903:	6a 2a                	push   $0x2a
  jmp alltraps
80106905:	e9 dd f7 ff ff       	jmp    801060e7 <alltraps>

8010690a <vector43>:
.globl vector43
vector43:
  pushl $0
8010690a:	6a 00                	push   $0x0
  pushl $43
8010690c:	6a 2b                	push   $0x2b
  jmp alltraps
8010690e:	e9 d4 f7 ff ff       	jmp    801060e7 <alltraps>

80106913 <vector44>:
.globl vector44
vector44:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $44
80106915:	6a 2c                	push   $0x2c
  jmp alltraps
80106917:	e9 cb f7 ff ff       	jmp    801060e7 <alltraps>

8010691c <vector45>:
.globl vector45
vector45:
  pushl $0
8010691c:	6a 00                	push   $0x0
  pushl $45
8010691e:	6a 2d                	push   $0x2d
  jmp alltraps
80106920:	e9 c2 f7 ff ff       	jmp    801060e7 <alltraps>

80106925 <vector46>:
.globl vector46
vector46:
  pushl $0
80106925:	6a 00                	push   $0x0
  pushl $46
80106927:	6a 2e                	push   $0x2e
  jmp alltraps
80106929:	e9 b9 f7 ff ff       	jmp    801060e7 <alltraps>

8010692e <vector47>:
.globl vector47
vector47:
  pushl $0
8010692e:	6a 00                	push   $0x0
  pushl $47
80106930:	6a 2f                	push   $0x2f
  jmp alltraps
80106932:	e9 b0 f7 ff ff       	jmp    801060e7 <alltraps>

80106937 <vector48>:
.globl vector48
vector48:
  pushl $0
80106937:	6a 00                	push   $0x0
  pushl $48
80106939:	6a 30                	push   $0x30
  jmp alltraps
8010693b:	e9 a7 f7 ff ff       	jmp    801060e7 <alltraps>

80106940 <vector49>:
.globl vector49
vector49:
  pushl $0
80106940:	6a 00                	push   $0x0
  pushl $49
80106942:	6a 31                	push   $0x31
  jmp alltraps
80106944:	e9 9e f7 ff ff       	jmp    801060e7 <alltraps>

80106949 <vector50>:
.globl vector50
vector50:
  pushl $0
80106949:	6a 00                	push   $0x0
  pushl $50
8010694b:	6a 32                	push   $0x32
  jmp alltraps
8010694d:	e9 95 f7 ff ff       	jmp    801060e7 <alltraps>

80106952 <vector51>:
.globl vector51
vector51:
  pushl $0
80106952:	6a 00                	push   $0x0
  pushl $51
80106954:	6a 33                	push   $0x33
  jmp alltraps
80106956:	e9 8c f7 ff ff       	jmp    801060e7 <alltraps>

8010695b <vector52>:
.globl vector52
vector52:
  pushl $0
8010695b:	6a 00                	push   $0x0
  pushl $52
8010695d:	6a 34                	push   $0x34
  jmp alltraps
8010695f:	e9 83 f7 ff ff       	jmp    801060e7 <alltraps>

80106964 <vector53>:
.globl vector53
vector53:
  pushl $0
80106964:	6a 00                	push   $0x0
  pushl $53
80106966:	6a 35                	push   $0x35
  jmp alltraps
80106968:	e9 7a f7 ff ff       	jmp    801060e7 <alltraps>

8010696d <vector54>:
.globl vector54
vector54:
  pushl $0
8010696d:	6a 00                	push   $0x0
  pushl $54
8010696f:	6a 36                	push   $0x36
  jmp alltraps
80106971:	e9 71 f7 ff ff       	jmp    801060e7 <alltraps>

80106976 <vector55>:
.globl vector55
vector55:
  pushl $0
80106976:	6a 00                	push   $0x0
  pushl $55
80106978:	6a 37                	push   $0x37
  jmp alltraps
8010697a:	e9 68 f7 ff ff       	jmp    801060e7 <alltraps>

8010697f <vector56>:
.globl vector56
vector56:
  pushl $0
8010697f:	6a 00                	push   $0x0
  pushl $56
80106981:	6a 38                	push   $0x38
  jmp alltraps
80106983:	e9 5f f7 ff ff       	jmp    801060e7 <alltraps>

80106988 <vector57>:
.globl vector57
vector57:
  pushl $0
80106988:	6a 00                	push   $0x0
  pushl $57
8010698a:	6a 39                	push   $0x39
  jmp alltraps
8010698c:	e9 56 f7 ff ff       	jmp    801060e7 <alltraps>

80106991 <vector58>:
.globl vector58
vector58:
  pushl $0
80106991:	6a 00                	push   $0x0
  pushl $58
80106993:	6a 3a                	push   $0x3a
  jmp alltraps
80106995:	e9 4d f7 ff ff       	jmp    801060e7 <alltraps>

8010699a <vector59>:
.globl vector59
vector59:
  pushl $0
8010699a:	6a 00                	push   $0x0
  pushl $59
8010699c:	6a 3b                	push   $0x3b
  jmp alltraps
8010699e:	e9 44 f7 ff ff       	jmp    801060e7 <alltraps>

801069a3 <vector60>:
.globl vector60
vector60:
  pushl $0
801069a3:	6a 00                	push   $0x0
  pushl $60
801069a5:	6a 3c                	push   $0x3c
  jmp alltraps
801069a7:	e9 3b f7 ff ff       	jmp    801060e7 <alltraps>

801069ac <vector61>:
.globl vector61
vector61:
  pushl $0
801069ac:	6a 00                	push   $0x0
  pushl $61
801069ae:	6a 3d                	push   $0x3d
  jmp alltraps
801069b0:	e9 32 f7 ff ff       	jmp    801060e7 <alltraps>

801069b5 <vector62>:
.globl vector62
vector62:
  pushl $0
801069b5:	6a 00                	push   $0x0
  pushl $62
801069b7:	6a 3e                	push   $0x3e
  jmp alltraps
801069b9:	e9 29 f7 ff ff       	jmp    801060e7 <alltraps>

801069be <vector63>:
.globl vector63
vector63:
  pushl $0
801069be:	6a 00                	push   $0x0
  pushl $63
801069c0:	6a 3f                	push   $0x3f
  jmp alltraps
801069c2:	e9 20 f7 ff ff       	jmp    801060e7 <alltraps>

801069c7 <vector64>:
.globl vector64
vector64:
  pushl $0
801069c7:	6a 00                	push   $0x0
  pushl $64
801069c9:	6a 40                	push   $0x40
  jmp alltraps
801069cb:	e9 17 f7 ff ff       	jmp    801060e7 <alltraps>

801069d0 <vector65>:
.globl vector65
vector65:
  pushl $0
801069d0:	6a 00                	push   $0x0
  pushl $65
801069d2:	6a 41                	push   $0x41
  jmp alltraps
801069d4:	e9 0e f7 ff ff       	jmp    801060e7 <alltraps>

801069d9 <vector66>:
.globl vector66
vector66:
  pushl $0
801069d9:	6a 00                	push   $0x0
  pushl $66
801069db:	6a 42                	push   $0x42
  jmp alltraps
801069dd:	e9 05 f7 ff ff       	jmp    801060e7 <alltraps>

801069e2 <vector67>:
.globl vector67
vector67:
  pushl $0
801069e2:	6a 00                	push   $0x0
  pushl $67
801069e4:	6a 43                	push   $0x43
  jmp alltraps
801069e6:	e9 fc f6 ff ff       	jmp    801060e7 <alltraps>

801069eb <vector68>:
.globl vector68
vector68:
  pushl $0
801069eb:	6a 00                	push   $0x0
  pushl $68
801069ed:	6a 44                	push   $0x44
  jmp alltraps
801069ef:	e9 f3 f6 ff ff       	jmp    801060e7 <alltraps>

801069f4 <vector69>:
.globl vector69
vector69:
  pushl $0
801069f4:	6a 00                	push   $0x0
  pushl $69
801069f6:	6a 45                	push   $0x45
  jmp alltraps
801069f8:	e9 ea f6 ff ff       	jmp    801060e7 <alltraps>

801069fd <vector70>:
.globl vector70
vector70:
  pushl $0
801069fd:	6a 00                	push   $0x0
  pushl $70
801069ff:	6a 46                	push   $0x46
  jmp alltraps
80106a01:	e9 e1 f6 ff ff       	jmp    801060e7 <alltraps>

80106a06 <vector71>:
.globl vector71
vector71:
  pushl $0
80106a06:	6a 00                	push   $0x0
  pushl $71
80106a08:	6a 47                	push   $0x47
  jmp alltraps
80106a0a:	e9 d8 f6 ff ff       	jmp    801060e7 <alltraps>

80106a0f <vector72>:
.globl vector72
vector72:
  pushl $0
80106a0f:	6a 00                	push   $0x0
  pushl $72
80106a11:	6a 48                	push   $0x48
  jmp alltraps
80106a13:	e9 cf f6 ff ff       	jmp    801060e7 <alltraps>

80106a18 <vector73>:
.globl vector73
vector73:
  pushl $0
80106a18:	6a 00                	push   $0x0
  pushl $73
80106a1a:	6a 49                	push   $0x49
  jmp alltraps
80106a1c:	e9 c6 f6 ff ff       	jmp    801060e7 <alltraps>

80106a21 <vector74>:
.globl vector74
vector74:
  pushl $0
80106a21:	6a 00                	push   $0x0
  pushl $74
80106a23:	6a 4a                	push   $0x4a
  jmp alltraps
80106a25:	e9 bd f6 ff ff       	jmp    801060e7 <alltraps>

80106a2a <vector75>:
.globl vector75
vector75:
  pushl $0
80106a2a:	6a 00                	push   $0x0
  pushl $75
80106a2c:	6a 4b                	push   $0x4b
  jmp alltraps
80106a2e:	e9 b4 f6 ff ff       	jmp    801060e7 <alltraps>

80106a33 <vector76>:
.globl vector76
vector76:
  pushl $0
80106a33:	6a 00                	push   $0x0
  pushl $76
80106a35:	6a 4c                	push   $0x4c
  jmp alltraps
80106a37:	e9 ab f6 ff ff       	jmp    801060e7 <alltraps>

80106a3c <vector77>:
.globl vector77
vector77:
  pushl $0
80106a3c:	6a 00                	push   $0x0
  pushl $77
80106a3e:	6a 4d                	push   $0x4d
  jmp alltraps
80106a40:	e9 a2 f6 ff ff       	jmp    801060e7 <alltraps>

80106a45 <vector78>:
.globl vector78
vector78:
  pushl $0
80106a45:	6a 00                	push   $0x0
  pushl $78
80106a47:	6a 4e                	push   $0x4e
  jmp alltraps
80106a49:	e9 99 f6 ff ff       	jmp    801060e7 <alltraps>

80106a4e <vector79>:
.globl vector79
vector79:
  pushl $0
80106a4e:	6a 00                	push   $0x0
  pushl $79
80106a50:	6a 4f                	push   $0x4f
  jmp alltraps
80106a52:	e9 90 f6 ff ff       	jmp    801060e7 <alltraps>

80106a57 <vector80>:
.globl vector80
vector80:
  pushl $0
80106a57:	6a 00                	push   $0x0
  pushl $80
80106a59:	6a 50                	push   $0x50
  jmp alltraps
80106a5b:	e9 87 f6 ff ff       	jmp    801060e7 <alltraps>

80106a60 <vector81>:
.globl vector81
vector81:
  pushl $0
80106a60:	6a 00                	push   $0x0
  pushl $81
80106a62:	6a 51                	push   $0x51
  jmp alltraps
80106a64:	e9 7e f6 ff ff       	jmp    801060e7 <alltraps>

80106a69 <vector82>:
.globl vector82
vector82:
  pushl $0
80106a69:	6a 00                	push   $0x0
  pushl $82
80106a6b:	6a 52                	push   $0x52
  jmp alltraps
80106a6d:	e9 75 f6 ff ff       	jmp    801060e7 <alltraps>

80106a72 <vector83>:
.globl vector83
vector83:
  pushl $0
80106a72:	6a 00                	push   $0x0
  pushl $83
80106a74:	6a 53                	push   $0x53
  jmp alltraps
80106a76:	e9 6c f6 ff ff       	jmp    801060e7 <alltraps>

80106a7b <vector84>:
.globl vector84
vector84:
  pushl $0
80106a7b:	6a 00                	push   $0x0
  pushl $84
80106a7d:	6a 54                	push   $0x54
  jmp alltraps
80106a7f:	e9 63 f6 ff ff       	jmp    801060e7 <alltraps>

80106a84 <vector85>:
.globl vector85
vector85:
  pushl $0
80106a84:	6a 00                	push   $0x0
  pushl $85
80106a86:	6a 55                	push   $0x55
  jmp alltraps
80106a88:	e9 5a f6 ff ff       	jmp    801060e7 <alltraps>

80106a8d <vector86>:
.globl vector86
vector86:
  pushl $0
80106a8d:	6a 00                	push   $0x0
  pushl $86
80106a8f:	6a 56                	push   $0x56
  jmp alltraps
80106a91:	e9 51 f6 ff ff       	jmp    801060e7 <alltraps>

80106a96 <vector87>:
.globl vector87
vector87:
  pushl $0
80106a96:	6a 00                	push   $0x0
  pushl $87
80106a98:	6a 57                	push   $0x57
  jmp alltraps
80106a9a:	e9 48 f6 ff ff       	jmp    801060e7 <alltraps>

80106a9f <vector88>:
.globl vector88
vector88:
  pushl $0
80106a9f:	6a 00                	push   $0x0
  pushl $88
80106aa1:	6a 58                	push   $0x58
  jmp alltraps
80106aa3:	e9 3f f6 ff ff       	jmp    801060e7 <alltraps>

80106aa8 <vector89>:
.globl vector89
vector89:
  pushl $0
80106aa8:	6a 00                	push   $0x0
  pushl $89
80106aaa:	6a 59                	push   $0x59
  jmp alltraps
80106aac:	e9 36 f6 ff ff       	jmp    801060e7 <alltraps>

80106ab1 <vector90>:
.globl vector90
vector90:
  pushl $0
80106ab1:	6a 00                	push   $0x0
  pushl $90
80106ab3:	6a 5a                	push   $0x5a
  jmp alltraps
80106ab5:	e9 2d f6 ff ff       	jmp    801060e7 <alltraps>

80106aba <vector91>:
.globl vector91
vector91:
  pushl $0
80106aba:	6a 00                	push   $0x0
  pushl $91
80106abc:	6a 5b                	push   $0x5b
  jmp alltraps
80106abe:	e9 24 f6 ff ff       	jmp    801060e7 <alltraps>

80106ac3 <vector92>:
.globl vector92
vector92:
  pushl $0
80106ac3:	6a 00                	push   $0x0
  pushl $92
80106ac5:	6a 5c                	push   $0x5c
  jmp alltraps
80106ac7:	e9 1b f6 ff ff       	jmp    801060e7 <alltraps>

80106acc <vector93>:
.globl vector93
vector93:
  pushl $0
80106acc:	6a 00                	push   $0x0
  pushl $93
80106ace:	6a 5d                	push   $0x5d
  jmp alltraps
80106ad0:	e9 12 f6 ff ff       	jmp    801060e7 <alltraps>

80106ad5 <vector94>:
.globl vector94
vector94:
  pushl $0
80106ad5:	6a 00                	push   $0x0
  pushl $94
80106ad7:	6a 5e                	push   $0x5e
  jmp alltraps
80106ad9:	e9 09 f6 ff ff       	jmp    801060e7 <alltraps>

80106ade <vector95>:
.globl vector95
vector95:
  pushl $0
80106ade:	6a 00                	push   $0x0
  pushl $95
80106ae0:	6a 5f                	push   $0x5f
  jmp alltraps
80106ae2:	e9 00 f6 ff ff       	jmp    801060e7 <alltraps>

80106ae7 <vector96>:
.globl vector96
vector96:
  pushl $0
80106ae7:	6a 00                	push   $0x0
  pushl $96
80106ae9:	6a 60                	push   $0x60
  jmp alltraps
80106aeb:	e9 f7 f5 ff ff       	jmp    801060e7 <alltraps>

80106af0 <vector97>:
.globl vector97
vector97:
  pushl $0
80106af0:	6a 00                	push   $0x0
  pushl $97
80106af2:	6a 61                	push   $0x61
  jmp alltraps
80106af4:	e9 ee f5 ff ff       	jmp    801060e7 <alltraps>

80106af9 <vector98>:
.globl vector98
vector98:
  pushl $0
80106af9:	6a 00                	push   $0x0
  pushl $98
80106afb:	6a 62                	push   $0x62
  jmp alltraps
80106afd:	e9 e5 f5 ff ff       	jmp    801060e7 <alltraps>

80106b02 <vector99>:
.globl vector99
vector99:
  pushl $0
80106b02:	6a 00                	push   $0x0
  pushl $99
80106b04:	6a 63                	push   $0x63
  jmp alltraps
80106b06:	e9 dc f5 ff ff       	jmp    801060e7 <alltraps>

80106b0b <vector100>:
.globl vector100
vector100:
  pushl $0
80106b0b:	6a 00                	push   $0x0
  pushl $100
80106b0d:	6a 64                	push   $0x64
  jmp alltraps
80106b0f:	e9 d3 f5 ff ff       	jmp    801060e7 <alltraps>

80106b14 <vector101>:
.globl vector101
vector101:
  pushl $0
80106b14:	6a 00                	push   $0x0
  pushl $101
80106b16:	6a 65                	push   $0x65
  jmp alltraps
80106b18:	e9 ca f5 ff ff       	jmp    801060e7 <alltraps>

80106b1d <vector102>:
.globl vector102
vector102:
  pushl $0
80106b1d:	6a 00                	push   $0x0
  pushl $102
80106b1f:	6a 66                	push   $0x66
  jmp alltraps
80106b21:	e9 c1 f5 ff ff       	jmp    801060e7 <alltraps>

80106b26 <vector103>:
.globl vector103
vector103:
  pushl $0
80106b26:	6a 00                	push   $0x0
  pushl $103
80106b28:	6a 67                	push   $0x67
  jmp alltraps
80106b2a:	e9 b8 f5 ff ff       	jmp    801060e7 <alltraps>

80106b2f <vector104>:
.globl vector104
vector104:
  pushl $0
80106b2f:	6a 00                	push   $0x0
  pushl $104
80106b31:	6a 68                	push   $0x68
  jmp alltraps
80106b33:	e9 af f5 ff ff       	jmp    801060e7 <alltraps>

80106b38 <vector105>:
.globl vector105
vector105:
  pushl $0
80106b38:	6a 00                	push   $0x0
  pushl $105
80106b3a:	6a 69                	push   $0x69
  jmp alltraps
80106b3c:	e9 a6 f5 ff ff       	jmp    801060e7 <alltraps>

80106b41 <vector106>:
.globl vector106
vector106:
  pushl $0
80106b41:	6a 00                	push   $0x0
  pushl $106
80106b43:	6a 6a                	push   $0x6a
  jmp alltraps
80106b45:	e9 9d f5 ff ff       	jmp    801060e7 <alltraps>

80106b4a <vector107>:
.globl vector107
vector107:
  pushl $0
80106b4a:	6a 00                	push   $0x0
  pushl $107
80106b4c:	6a 6b                	push   $0x6b
  jmp alltraps
80106b4e:	e9 94 f5 ff ff       	jmp    801060e7 <alltraps>

80106b53 <vector108>:
.globl vector108
vector108:
  pushl $0
80106b53:	6a 00                	push   $0x0
  pushl $108
80106b55:	6a 6c                	push   $0x6c
  jmp alltraps
80106b57:	e9 8b f5 ff ff       	jmp    801060e7 <alltraps>

80106b5c <vector109>:
.globl vector109
vector109:
  pushl $0
80106b5c:	6a 00                	push   $0x0
  pushl $109
80106b5e:	6a 6d                	push   $0x6d
  jmp alltraps
80106b60:	e9 82 f5 ff ff       	jmp    801060e7 <alltraps>

80106b65 <vector110>:
.globl vector110
vector110:
  pushl $0
80106b65:	6a 00                	push   $0x0
  pushl $110
80106b67:	6a 6e                	push   $0x6e
  jmp alltraps
80106b69:	e9 79 f5 ff ff       	jmp    801060e7 <alltraps>

80106b6e <vector111>:
.globl vector111
vector111:
  pushl $0
80106b6e:	6a 00                	push   $0x0
  pushl $111
80106b70:	6a 6f                	push   $0x6f
  jmp alltraps
80106b72:	e9 70 f5 ff ff       	jmp    801060e7 <alltraps>

80106b77 <vector112>:
.globl vector112
vector112:
  pushl $0
80106b77:	6a 00                	push   $0x0
  pushl $112
80106b79:	6a 70                	push   $0x70
  jmp alltraps
80106b7b:	e9 67 f5 ff ff       	jmp    801060e7 <alltraps>

80106b80 <vector113>:
.globl vector113
vector113:
  pushl $0
80106b80:	6a 00                	push   $0x0
  pushl $113
80106b82:	6a 71                	push   $0x71
  jmp alltraps
80106b84:	e9 5e f5 ff ff       	jmp    801060e7 <alltraps>

80106b89 <vector114>:
.globl vector114
vector114:
  pushl $0
80106b89:	6a 00                	push   $0x0
  pushl $114
80106b8b:	6a 72                	push   $0x72
  jmp alltraps
80106b8d:	e9 55 f5 ff ff       	jmp    801060e7 <alltraps>

80106b92 <vector115>:
.globl vector115
vector115:
  pushl $0
80106b92:	6a 00                	push   $0x0
  pushl $115
80106b94:	6a 73                	push   $0x73
  jmp alltraps
80106b96:	e9 4c f5 ff ff       	jmp    801060e7 <alltraps>

80106b9b <vector116>:
.globl vector116
vector116:
  pushl $0
80106b9b:	6a 00                	push   $0x0
  pushl $116
80106b9d:	6a 74                	push   $0x74
  jmp alltraps
80106b9f:	e9 43 f5 ff ff       	jmp    801060e7 <alltraps>

80106ba4 <vector117>:
.globl vector117
vector117:
  pushl $0
80106ba4:	6a 00                	push   $0x0
  pushl $117
80106ba6:	6a 75                	push   $0x75
  jmp alltraps
80106ba8:	e9 3a f5 ff ff       	jmp    801060e7 <alltraps>

80106bad <vector118>:
.globl vector118
vector118:
  pushl $0
80106bad:	6a 00                	push   $0x0
  pushl $118
80106baf:	6a 76                	push   $0x76
  jmp alltraps
80106bb1:	e9 31 f5 ff ff       	jmp    801060e7 <alltraps>

80106bb6 <vector119>:
.globl vector119
vector119:
  pushl $0
80106bb6:	6a 00                	push   $0x0
  pushl $119
80106bb8:	6a 77                	push   $0x77
  jmp alltraps
80106bba:	e9 28 f5 ff ff       	jmp    801060e7 <alltraps>

80106bbf <vector120>:
.globl vector120
vector120:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $120
80106bc1:	6a 78                	push   $0x78
  jmp alltraps
80106bc3:	e9 1f f5 ff ff       	jmp    801060e7 <alltraps>

80106bc8 <vector121>:
.globl vector121
vector121:
  pushl $0
80106bc8:	6a 00                	push   $0x0
  pushl $121
80106bca:	6a 79                	push   $0x79
  jmp alltraps
80106bcc:	e9 16 f5 ff ff       	jmp    801060e7 <alltraps>

80106bd1 <vector122>:
.globl vector122
vector122:
  pushl $0
80106bd1:	6a 00                	push   $0x0
  pushl $122
80106bd3:	6a 7a                	push   $0x7a
  jmp alltraps
80106bd5:	e9 0d f5 ff ff       	jmp    801060e7 <alltraps>

80106bda <vector123>:
.globl vector123
vector123:
  pushl $0
80106bda:	6a 00                	push   $0x0
  pushl $123
80106bdc:	6a 7b                	push   $0x7b
  jmp alltraps
80106bde:	e9 04 f5 ff ff       	jmp    801060e7 <alltraps>

80106be3 <vector124>:
.globl vector124
vector124:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $124
80106be5:	6a 7c                	push   $0x7c
  jmp alltraps
80106be7:	e9 fb f4 ff ff       	jmp    801060e7 <alltraps>

80106bec <vector125>:
.globl vector125
vector125:
  pushl $0
80106bec:	6a 00                	push   $0x0
  pushl $125
80106bee:	6a 7d                	push   $0x7d
  jmp alltraps
80106bf0:	e9 f2 f4 ff ff       	jmp    801060e7 <alltraps>

80106bf5 <vector126>:
.globl vector126
vector126:
  pushl $0
80106bf5:	6a 00                	push   $0x0
  pushl $126
80106bf7:	6a 7e                	push   $0x7e
  jmp alltraps
80106bf9:	e9 e9 f4 ff ff       	jmp    801060e7 <alltraps>

80106bfe <vector127>:
.globl vector127
vector127:
  pushl $0
80106bfe:	6a 00                	push   $0x0
  pushl $127
80106c00:	6a 7f                	push   $0x7f
  jmp alltraps
80106c02:	e9 e0 f4 ff ff       	jmp    801060e7 <alltraps>

80106c07 <vector128>:
.globl vector128
vector128:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $128
80106c09:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106c0e:	e9 d4 f4 ff ff       	jmp    801060e7 <alltraps>

80106c13 <vector129>:
.globl vector129
vector129:
  pushl $0
80106c13:	6a 00                	push   $0x0
  pushl $129
80106c15:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106c1a:	e9 c8 f4 ff ff       	jmp    801060e7 <alltraps>

80106c1f <vector130>:
.globl vector130
vector130:
  pushl $0
80106c1f:	6a 00                	push   $0x0
  pushl $130
80106c21:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106c26:	e9 bc f4 ff ff       	jmp    801060e7 <alltraps>

80106c2b <vector131>:
.globl vector131
vector131:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $131
80106c2d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106c32:	e9 b0 f4 ff ff       	jmp    801060e7 <alltraps>

80106c37 <vector132>:
.globl vector132
vector132:
  pushl $0
80106c37:	6a 00                	push   $0x0
  pushl $132
80106c39:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106c3e:	e9 a4 f4 ff ff       	jmp    801060e7 <alltraps>

80106c43 <vector133>:
.globl vector133
vector133:
  pushl $0
80106c43:	6a 00                	push   $0x0
  pushl $133
80106c45:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106c4a:	e9 98 f4 ff ff       	jmp    801060e7 <alltraps>

80106c4f <vector134>:
.globl vector134
vector134:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $134
80106c51:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106c56:	e9 8c f4 ff ff       	jmp    801060e7 <alltraps>

80106c5b <vector135>:
.globl vector135
vector135:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $135
80106c5d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106c62:	e9 80 f4 ff ff       	jmp    801060e7 <alltraps>

80106c67 <vector136>:
.globl vector136
vector136:
  pushl $0
80106c67:	6a 00                	push   $0x0
  pushl $136
80106c69:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106c6e:	e9 74 f4 ff ff       	jmp    801060e7 <alltraps>

80106c73 <vector137>:
.globl vector137
vector137:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $137
80106c75:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106c7a:	e9 68 f4 ff ff       	jmp    801060e7 <alltraps>

80106c7f <vector138>:
.globl vector138
vector138:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $138
80106c81:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106c86:	e9 5c f4 ff ff       	jmp    801060e7 <alltraps>

80106c8b <vector139>:
.globl vector139
vector139:
  pushl $0
80106c8b:	6a 00                	push   $0x0
  pushl $139
80106c8d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106c92:	e9 50 f4 ff ff       	jmp    801060e7 <alltraps>

80106c97 <vector140>:
.globl vector140
vector140:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $140
80106c99:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106c9e:	e9 44 f4 ff ff       	jmp    801060e7 <alltraps>

80106ca3 <vector141>:
.globl vector141
vector141:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $141
80106ca5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106caa:	e9 38 f4 ff ff       	jmp    801060e7 <alltraps>

80106caf <vector142>:
.globl vector142
vector142:
  pushl $0
80106caf:	6a 00                	push   $0x0
  pushl $142
80106cb1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106cb6:	e9 2c f4 ff ff       	jmp    801060e7 <alltraps>

80106cbb <vector143>:
.globl vector143
vector143:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $143
80106cbd:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106cc2:	e9 20 f4 ff ff       	jmp    801060e7 <alltraps>

80106cc7 <vector144>:
.globl vector144
vector144:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $144
80106cc9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106cce:	e9 14 f4 ff ff       	jmp    801060e7 <alltraps>

80106cd3 <vector145>:
.globl vector145
vector145:
  pushl $0
80106cd3:	6a 00                	push   $0x0
  pushl $145
80106cd5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106cda:	e9 08 f4 ff ff       	jmp    801060e7 <alltraps>

80106cdf <vector146>:
.globl vector146
vector146:
  pushl $0
80106cdf:	6a 00                	push   $0x0
  pushl $146
80106ce1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106ce6:	e9 fc f3 ff ff       	jmp    801060e7 <alltraps>

80106ceb <vector147>:
.globl vector147
vector147:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $147
80106ced:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106cf2:	e9 f0 f3 ff ff       	jmp    801060e7 <alltraps>

80106cf7 <vector148>:
.globl vector148
vector148:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $148
80106cf9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106cfe:	e9 e4 f3 ff ff       	jmp    801060e7 <alltraps>

80106d03 <vector149>:
.globl vector149
vector149:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $149
80106d05:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106d0a:	e9 d8 f3 ff ff       	jmp    801060e7 <alltraps>

80106d0f <vector150>:
.globl vector150
vector150:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $150
80106d11:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106d16:	e9 cc f3 ff ff       	jmp    801060e7 <alltraps>

80106d1b <vector151>:
.globl vector151
vector151:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $151
80106d1d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106d22:	e9 c0 f3 ff ff       	jmp    801060e7 <alltraps>

80106d27 <vector152>:
.globl vector152
vector152:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $152
80106d29:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106d2e:	e9 b4 f3 ff ff       	jmp    801060e7 <alltraps>

80106d33 <vector153>:
.globl vector153
vector153:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $153
80106d35:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106d3a:	e9 a8 f3 ff ff       	jmp    801060e7 <alltraps>

80106d3f <vector154>:
.globl vector154
vector154:
  pushl $0
80106d3f:	6a 00                	push   $0x0
  pushl $154
80106d41:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106d46:	e9 9c f3 ff ff       	jmp    801060e7 <alltraps>

80106d4b <vector155>:
.globl vector155
vector155:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $155
80106d4d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106d52:	e9 90 f3 ff ff       	jmp    801060e7 <alltraps>

80106d57 <vector156>:
.globl vector156
vector156:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $156
80106d59:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106d5e:	e9 84 f3 ff ff       	jmp    801060e7 <alltraps>

80106d63 <vector157>:
.globl vector157
vector157:
  pushl $0
80106d63:	6a 00                	push   $0x0
  pushl $157
80106d65:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106d6a:	e9 78 f3 ff ff       	jmp    801060e7 <alltraps>

80106d6f <vector158>:
.globl vector158
vector158:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $158
80106d71:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106d76:	e9 6c f3 ff ff       	jmp    801060e7 <alltraps>

80106d7b <vector159>:
.globl vector159
vector159:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $159
80106d7d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106d82:	e9 60 f3 ff ff       	jmp    801060e7 <alltraps>

80106d87 <vector160>:
.globl vector160
vector160:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $160
80106d89:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106d8e:	e9 54 f3 ff ff       	jmp    801060e7 <alltraps>

80106d93 <vector161>:
.globl vector161
vector161:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $161
80106d95:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106d9a:	e9 48 f3 ff ff       	jmp    801060e7 <alltraps>

80106d9f <vector162>:
.globl vector162
vector162:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $162
80106da1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106da6:	e9 3c f3 ff ff       	jmp    801060e7 <alltraps>

80106dab <vector163>:
.globl vector163
vector163:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $163
80106dad:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106db2:	e9 30 f3 ff ff       	jmp    801060e7 <alltraps>

80106db7 <vector164>:
.globl vector164
vector164:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $164
80106db9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106dbe:	e9 24 f3 ff ff       	jmp    801060e7 <alltraps>

80106dc3 <vector165>:
.globl vector165
vector165:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $165
80106dc5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106dca:	e9 18 f3 ff ff       	jmp    801060e7 <alltraps>

80106dcf <vector166>:
.globl vector166
vector166:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $166
80106dd1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106dd6:	e9 0c f3 ff ff       	jmp    801060e7 <alltraps>

80106ddb <vector167>:
.globl vector167
vector167:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $167
80106ddd:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106de2:	e9 00 f3 ff ff       	jmp    801060e7 <alltraps>

80106de7 <vector168>:
.globl vector168
vector168:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $168
80106de9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106dee:	e9 f4 f2 ff ff       	jmp    801060e7 <alltraps>

80106df3 <vector169>:
.globl vector169
vector169:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $169
80106df5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106dfa:	e9 e8 f2 ff ff       	jmp    801060e7 <alltraps>

80106dff <vector170>:
.globl vector170
vector170:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $170
80106e01:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106e06:	e9 dc f2 ff ff       	jmp    801060e7 <alltraps>

80106e0b <vector171>:
.globl vector171
vector171:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $171
80106e0d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106e12:	e9 d0 f2 ff ff       	jmp    801060e7 <alltraps>

80106e17 <vector172>:
.globl vector172
vector172:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $172
80106e19:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106e1e:	e9 c4 f2 ff ff       	jmp    801060e7 <alltraps>

80106e23 <vector173>:
.globl vector173
vector173:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $173
80106e25:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106e2a:	e9 b8 f2 ff ff       	jmp    801060e7 <alltraps>

80106e2f <vector174>:
.globl vector174
vector174:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $174
80106e31:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106e36:	e9 ac f2 ff ff       	jmp    801060e7 <alltraps>

80106e3b <vector175>:
.globl vector175
vector175:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $175
80106e3d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106e42:	e9 a0 f2 ff ff       	jmp    801060e7 <alltraps>

80106e47 <vector176>:
.globl vector176
vector176:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $176
80106e49:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106e4e:	e9 94 f2 ff ff       	jmp    801060e7 <alltraps>

80106e53 <vector177>:
.globl vector177
vector177:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $177
80106e55:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106e5a:	e9 88 f2 ff ff       	jmp    801060e7 <alltraps>

80106e5f <vector178>:
.globl vector178
vector178:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $178
80106e61:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106e66:	e9 7c f2 ff ff       	jmp    801060e7 <alltraps>

80106e6b <vector179>:
.globl vector179
vector179:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $179
80106e6d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106e72:	e9 70 f2 ff ff       	jmp    801060e7 <alltraps>

80106e77 <vector180>:
.globl vector180
vector180:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $180
80106e79:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106e7e:	e9 64 f2 ff ff       	jmp    801060e7 <alltraps>

80106e83 <vector181>:
.globl vector181
vector181:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $181
80106e85:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106e8a:	e9 58 f2 ff ff       	jmp    801060e7 <alltraps>

80106e8f <vector182>:
.globl vector182
vector182:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $182
80106e91:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106e96:	e9 4c f2 ff ff       	jmp    801060e7 <alltraps>

80106e9b <vector183>:
.globl vector183
vector183:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $183
80106e9d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106ea2:	e9 40 f2 ff ff       	jmp    801060e7 <alltraps>

80106ea7 <vector184>:
.globl vector184
vector184:
  pushl $0
80106ea7:	6a 00                	push   $0x0
  pushl $184
80106ea9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106eae:	e9 34 f2 ff ff       	jmp    801060e7 <alltraps>

80106eb3 <vector185>:
.globl vector185
vector185:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $185
80106eb5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106eba:	e9 28 f2 ff ff       	jmp    801060e7 <alltraps>

80106ebf <vector186>:
.globl vector186
vector186:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $186
80106ec1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106ec6:	e9 1c f2 ff ff       	jmp    801060e7 <alltraps>

80106ecb <vector187>:
.globl vector187
vector187:
  pushl $0
80106ecb:	6a 00                	push   $0x0
  pushl $187
80106ecd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106ed2:	e9 10 f2 ff ff       	jmp    801060e7 <alltraps>

80106ed7 <vector188>:
.globl vector188
vector188:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $188
80106ed9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106ede:	e9 04 f2 ff ff       	jmp    801060e7 <alltraps>

80106ee3 <vector189>:
.globl vector189
vector189:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $189
80106ee5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106eea:	e9 f8 f1 ff ff       	jmp    801060e7 <alltraps>

80106eef <vector190>:
.globl vector190
vector190:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $190
80106ef1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106ef6:	e9 ec f1 ff ff       	jmp    801060e7 <alltraps>

80106efb <vector191>:
.globl vector191
vector191:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $191
80106efd:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106f02:	e9 e0 f1 ff ff       	jmp    801060e7 <alltraps>

80106f07 <vector192>:
.globl vector192
vector192:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $192
80106f09:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106f0e:	e9 d4 f1 ff ff       	jmp    801060e7 <alltraps>

80106f13 <vector193>:
.globl vector193
vector193:
  pushl $0
80106f13:	6a 00                	push   $0x0
  pushl $193
80106f15:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106f1a:	e9 c8 f1 ff ff       	jmp    801060e7 <alltraps>

80106f1f <vector194>:
.globl vector194
vector194:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $194
80106f21:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106f26:	e9 bc f1 ff ff       	jmp    801060e7 <alltraps>

80106f2b <vector195>:
.globl vector195
vector195:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $195
80106f2d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106f32:	e9 b0 f1 ff ff       	jmp    801060e7 <alltraps>

80106f37 <vector196>:
.globl vector196
vector196:
  pushl $0
80106f37:	6a 00                	push   $0x0
  pushl $196
80106f39:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106f3e:	e9 a4 f1 ff ff       	jmp    801060e7 <alltraps>

80106f43 <vector197>:
.globl vector197
vector197:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $197
80106f45:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106f4a:	e9 98 f1 ff ff       	jmp    801060e7 <alltraps>

80106f4f <vector198>:
.globl vector198
vector198:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $198
80106f51:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106f56:	e9 8c f1 ff ff       	jmp    801060e7 <alltraps>

80106f5b <vector199>:
.globl vector199
vector199:
  pushl $0
80106f5b:	6a 00                	push   $0x0
  pushl $199
80106f5d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106f62:	e9 80 f1 ff ff       	jmp    801060e7 <alltraps>

80106f67 <vector200>:
.globl vector200
vector200:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $200
80106f69:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106f6e:	e9 74 f1 ff ff       	jmp    801060e7 <alltraps>

80106f73 <vector201>:
.globl vector201
vector201:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $201
80106f75:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106f7a:	e9 68 f1 ff ff       	jmp    801060e7 <alltraps>

80106f7f <vector202>:
.globl vector202
vector202:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $202
80106f81:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106f86:	e9 5c f1 ff ff       	jmp    801060e7 <alltraps>

80106f8b <vector203>:
.globl vector203
vector203:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $203
80106f8d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106f92:	e9 50 f1 ff ff       	jmp    801060e7 <alltraps>

80106f97 <vector204>:
.globl vector204
vector204:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $204
80106f99:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106f9e:	e9 44 f1 ff ff       	jmp    801060e7 <alltraps>

80106fa3 <vector205>:
.globl vector205
vector205:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $205
80106fa5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106faa:	e9 38 f1 ff ff       	jmp    801060e7 <alltraps>

80106faf <vector206>:
.globl vector206
vector206:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $206
80106fb1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106fb6:	e9 2c f1 ff ff       	jmp    801060e7 <alltraps>

80106fbb <vector207>:
.globl vector207
vector207:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $207
80106fbd:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106fc2:	e9 20 f1 ff ff       	jmp    801060e7 <alltraps>

80106fc7 <vector208>:
.globl vector208
vector208:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $208
80106fc9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106fce:	e9 14 f1 ff ff       	jmp    801060e7 <alltraps>

80106fd3 <vector209>:
.globl vector209
vector209:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $209
80106fd5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106fda:	e9 08 f1 ff ff       	jmp    801060e7 <alltraps>

80106fdf <vector210>:
.globl vector210
vector210:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $210
80106fe1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106fe6:	e9 fc f0 ff ff       	jmp    801060e7 <alltraps>

80106feb <vector211>:
.globl vector211
vector211:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $211
80106fed:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106ff2:	e9 f0 f0 ff ff       	jmp    801060e7 <alltraps>

80106ff7 <vector212>:
.globl vector212
vector212:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $212
80106ff9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106ffe:	e9 e4 f0 ff ff       	jmp    801060e7 <alltraps>

80107003 <vector213>:
.globl vector213
vector213:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $213
80107005:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010700a:	e9 d8 f0 ff ff       	jmp    801060e7 <alltraps>

8010700f <vector214>:
.globl vector214
vector214:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $214
80107011:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107016:	e9 cc f0 ff ff       	jmp    801060e7 <alltraps>

8010701b <vector215>:
.globl vector215
vector215:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $215
8010701d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107022:	e9 c0 f0 ff ff       	jmp    801060e7 <alltraps>

80107027 <vector216>:
.globl vector216
vector216:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $216
80107029:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010702e:	e9 b4 f0 ff ff       	jmp    801060e7 <alltraps>

80107033 <vector217>:
.globl vector217
vector217:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $217
80107035:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010703a:	e9 a8 f0 ff ff       	jmp    801060e7 <alltraps>

8010703f <vector218>:
.globl vector218
vector218:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $218
80107041:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107046:	e9 9c f0 ff ff       	jmp    801060e7 <alltraps>

8010704b <vector219>:
.globl vector219
vector219:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $219
8010704d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107052:	e9 90 f0 ff ff       	jmp    801060e7 <alltraps>

80107057 <vector220>:
.globl vector220
vector220:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $220
80107059:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010705e:	e9 84 f0 ff ff       	jmp    801060e7 <alltraps>

80107063 <vector221>:
.globl vector221
vector221:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $221
80107065:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010706a:	e9 78 f0 ff ff       	jmp    801060e7 <alltraps>

8010706f <vector222>:
.globl vector222
vector222:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $222
80107071:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107076:	e9 6c f0 ff ff       	jmp    801060e7 <alltraps>

8010707b <vector223>:
.globl vector223
vector223:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $223
8010707d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107082:	e9 60 f0 ff ff       	jmp    801060e7 <alltraps>

80107087 <vector224>:
.globl vector224
vector224:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $224
80107089:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010708e:	e9 54 f0 ff ff       	jmp    801060e7 <alltraps>

80107093 <vector225>:
.globl vector225
vector225:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $225
80107095:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010709a:	e9 48 f0 ff ff       	jmp    801060e7 <alltraps>

8010709f <vector226>:
.globl vector226
vector226:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $226
801070a1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801070a6:	e9 3c f0 ff ff       	jmp    801060e7 <alltraps>

801070ab <vector227>:
.globl vector227
vector227:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $227
801070ad:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801070b2:	e9 30 f0 ff ff       	jmp    801060e7 <alltraps>

801070b7 <vector228>:
.globl vector228
vector228:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $228
801070b9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801070be:	e9 24 f0 ff ff       	jmp    801060e7 <alltraps>

801070c3 <vector229>:
.globl vector229
vector229:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $229
801070c5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801070ca:	e9 18 f0 ff ff       	jmp    801060e7 <alltraps>

801070cf <vector230>:
.globl vector230
vector230:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $230
801070d1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801070d6:	e9 0c f0 ff ff       	jmp    801060e7 <alltraps>

801070db <vector231>:
.globl vector231
vector231:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $231
801070dd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801070e2:	e9 00 f0 ff ff       	jmp    801060e7 <alltraps>

801070e7 <vector232>:
.globl vector232
vector232:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $232
801070e9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801070ee:	e9 f4 ef ff ff       	jmp    801060e7 <alltraps>

801070f3 <vector233>:
.globl vector233
vector233:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $233
801070f5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801070fa:	e9 e8 ef ff ff       	jmp    801060e7 <alltraps>

801070ff <vector234>:
.globl vector234
vector234:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $234
80107101:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107106:	e9 dc ef ff ff       	jmp    801060e7 <alltraps>

8010710b <vector235>:
.globl vector235
vector235:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $235
8010710d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107112:	e9 d0 ef ff ff       	jmp    801060e7 <alltraps>

80107117 <vector236>:
.globl vector236
vector236:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $236
80107119:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010711e:	e9 c4 ef ff ff       	jmp    801060e7 <alltraps>

80107123 <vector237>:
.globl vector237
vector237:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $237
80107125:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010712a:	e9 b8 ef ff ff       	jmp    801060e7 <alltraps>

8010712f <vector238>:
.globl vector238
vector238:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $238
80107131:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107136:	e9 ac ef ff ff       	jmp    801060e7 <alltraps>

8010713b <vector239>:
.globl vector239
vector239:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $239
8010713d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107142:	e9 a0 ef ff ff       	jmp    801060e7 <alltraps>

80107147 <vector240>:
.globl vector240
vector240:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $240
80107149:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010714e:	e9 94 ef ff ff       	jmp    801060e7 <alltraps>

80107153 <vector241>:
.globl vector241
vector241:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $241
80107155:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010715a:	e9 88 ef ff ff       	jmp    801060e7 <alltraps>

8010715f <vector242>:
.globl vector242
vector242:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $242
80107161:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107166:	e9 7c ef ff ff       	jmp    801060e7 <alltraps>

8010716b <vector243>:
.globl vector243
vector243:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $243
8010716d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107172:	e9 70 ef ff ff       	jmp    801060e7 <alltraps>

80107177 <vector244>:
.globl vector244
vector244:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $244
80107179:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010717e:	e9 64 ef ff ff       	jmp    801060e7 <alltraps>

80107183 <vector245>:
.globl vector245
vector245:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $245
80107185:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010718a:	e9 58 ef ff ff       	jmp    801060e7 <alltraps>

8010718f <vector246>:
.globl vector246
vector246:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $246
80107191:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107196:	e9 4c ef ff ff       	jmp    801060e7 <alltraps>

8010719b <vector247>:
.globl vector247
vector247:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $247
8010719d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801071a2:	e9 40 ef ff ff       	jmp    801060e7 <alltraps>

801071a7 <vector248>:
.globl vector248
vector248:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $248
801071a9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801071ae:	e9 34 ef ff ff       	jmp    801060e7 <alltraps>

801071b3 <vector249>:
.globl vector249
vector249:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $249
801071b5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801071ba:	e9 28 ef ff ff       	jmp    801060e7 <alltraps>

801071bf <vector250>:
.globl vector250
vector250:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $250
801071c1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801071c6:	e9 1c ef ff ff       	jmp    801060e7 <alltraps>

801071cb <vector251>:
.globl vector251
vector251:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $251
801071cd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801071d2:	e9 10 ef ff ff       	jmp    801060e7 <alltraps>

801071d7 <vector252>:
.globl vector252
vector252:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $252
801071d9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801071de:	e9 04 ef ff ff       	jmp    801060e7 <alltraps>

801071e3 <vector253>:
.globl vector253
vector253:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $253
801071e5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801071ea:	e9 f8 ee ff ff       	jmp    801060e7 <alltraps>

801071ef <vector254>:
.globl vector254
vector254:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $254
801071f1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801071f6:	e9 ec ee ff ff       	jmp    801060e7 <alltraps>

801071fb <vector255>:
.globl vector255
vector255:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $255
801071fd:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107202:	e9 e0 ee ff ff       	jmp    801060e7 <alltraps>
80107207:	66 90                	xchg   %ax,%ax
80107209:	66 90                	xchg   %ax,%ax
8010720b:	66 90                	xchg   %ax,%ax
8010720d:	66 90                	xchg   %ax,%ax
8010720f:	90                   	nop

80107210 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107210:	55                   	push   %ebp
80107211:	89 e5                	mov    %esp,%ebp
80107213:	57                   	push   %edi
80107214:	56                   	push   %esi
80107215:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80107216:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
8010721c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107222:	83 ec 1c             	sub    $0x1c,%esp
80107225:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107228:	39 d3                	cmp    %edx,%ebx
8010722a:	73 49                	jae    80107275 <deallocuvm.part.0+0x65>
8010722c:	89 c7                	mov    %eax,%edi
8010722e:	eb 0c                	jmp    8010723c <deallocuvm.part.0+0x2c>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107230:	83 c0 01             	add    $0x1,%eax
80107233:	c1 e0 16             	shl    $0x16,%eax
80107236:	89 c3                	mov    %eax,%ebx
  for(; a  < oldsz; a += PGSIZE){
80107238:	39 da                	cmp    %ebx,%edx
8010723a:	76 39                	jbe    80107275 <deallocuvm.part.0+0x65>
  pde = &pgdir[PDX(va)];
8010723c:	89 d8                	mov    %ebx,%eax
8010723e:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80107241:	8b 0c 87             	mov    (%edi,%eax,4),%ecx
80107244:	f6 c1 01             	test   $0x1,%cl
80107247:	74 e7                	je     80107230 <deallocuvm.part.0+0x20>
  return &pgtab[PTX(va)];
80107249:	89 de                	mov    %ebx,%esi
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010724b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
80107251:	c1 ee 0a             	shr    $0xa,%esi
80107254:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
8010725a:	8d b4 31 00 00 00 80 	lea    -0x80000000(%ecx,%esi,1),%esi
    if(!pte)
80107261:	85 f6                	test   %esi,%esi
80107263:	74 cb                	je     80107230 <deallocuvm.part.0+0x20>
    else if((*pte & PTE_P) != 0){
80107265:	8b 06                	mov    (%esi),%eax
80107267:	a8 01                	test   $0x1,%al
80107269:	75 15                	jne    80107280 <deallocuvm.part.0+0x70>
  for(; a  < oldsz; a += PGSIZE){
8010726b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107271:	39 da                	cmp    %ebx,%edx
80107273:	77 c7                	ja     8010723c <deallocuvm.part.0+0x2c>
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
80107275:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107278:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010727b:	5b                   	pop    %ebx
8010727c:	5e                   	pop    %esi
8010727d:	5f                   	pop    %edi
8010727e:	5d                   	pop    %ebp
8010727f:	c3                   	ret    
      if(pa == 0)
80107280:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107285:	74 25                	je     801072ac <deallocuvm.part.0+0x9c>
      kfree(v);
80107287:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010728a:	05 00 00 00 80       	add    $0x80000000,%eax
8010728f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107292:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      kfree(v);
80107298:	50                   	push   %eax
80107299:	e8 22 b2 ff ff       	call   801024c0 <kfree>
      *pte = 0;
8010729e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  for(; a  < oldsz; a += PGSIZE){
801072a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801072a7:	83 c4 10             	add    $0x10,%esp
801072aa:	eb 8c                	jmp    80107238 <deallocuvm.part.0+0x28>
        panic("kfree");
801072ac:	83 ec 0c             	sub    $0xc,%esp
801072af:	68 26 81 10 80       	push   $0x80108126
801072b4:	e8 c7 90 ff ff       	call   80100380 <panic>
801072b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801072c0 <mappages>:
{
801072c0:	55                   	push   %ebp
801072c1:	89 e5                	mov    %esp,%ebp
801072c3:	57                   	push   %edi
801072c4:	56                   	push   %esi
801072c5:	53                   	push   %ebx
  a = (char*)PGROUNDDOWN((uint)va);
801072c6:	89 d3                	mov    %edx,%ebx
801072c8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
801072ce:	83 ec 1c             	sub    $0x1c,%esp
801072d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801072d4:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
801072d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
801072e0:	8b 45 08             	mov    0x8(%ebp),%eax
801072e3:	29 d8                	sub    %ebx,%eax
801072e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801072e8:	eb 3d                	jmp    80107327 <mappages+0x67>
801072ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
801072f0:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801072f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
801072f7:	c1 ea 0a             	shr    $0xa,%edx
801072fa:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107300:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107307:	85 c0                	test   %eax,%eax
80107309:	74 75                	je     80107380 <mappages+0xc0>
    if(*pte & PTE_P)
8010730b:	f6 00 01             	testb  $0x1,(%eax)
8010730e:	0f 85 86 00 00 00    	jne    8010739a <mappages+0xda>
    *pte = pa | perm | PTE_P;
80107314:	0b 75 0c             	or     0xc(%ebp),%esi
80107317:	83 ce 01             	or     $0x1,%esi
8010731a:	89 30                	mov    %esi,(%eax)
    if(a == last)
8010731c:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
8010731f:	74 6f                	je     80107390 <mappages+0xd0>
    a += PGSIZE;
80107321:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for(;;){
80107327:	8b 45 e0             	mov    -0x20(%ebp),%eax
  pde = &pgdir[PDX(va)];
8010732a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010732d:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80107330:	89 d8                	mov    %ebx,%eax
80107332:	c1 e8 16             	shr    $0x16,%eax
80107335:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
  if(*pde & PTE_P){
80107338:	8b 07                	mov    (%edi),%eax
8010733a:	a8 01                	test   $0x1,%al
8010733c:	75 b2                	jne    801072f0 <mappages+0x30>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010733e:	e8 3d b3 ff ff       	call   80102680 <kalloc>
80107343:	85 c0                	test   %eax,%eax
80107345:	74 39                	je     80107380 <mappages+0xc0>
    memset(pgtab, 0, PGSIZE);
80107347:	83 ec 04             	sub    $0x4,%esp
8010734a:	89 45 d8             	mov    %eax,-0x28(%ebp)
8010734d:	68 00 10 00 00       	push   $0x1000
80107352:	6a 00                	push   $0x0
80107354:	50                   	push   %eax
80107355:	e8 c6 da ff ff       	call   80104e20 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010735a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  return &pgtab[PTX(va)];
8010735d:	83 c4 10             	add    $0x10,%esp
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107360:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
80107366:	83 c8 07             	or     $0x7,%eax
80107369:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
8010736b:	89 d8                	mov    %ebx,%eax
8010736d:	c1 e8 0a             	shr    $0xa,%eax
80107370:	25 fc 0f 00 00       	and    $0xffc,%eax
80107375:	01 d0                	add    %edx,%eax
80107377:	eb 92                	jmp    8010730b <mappages+0x4b>
80107379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
80107380:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107383:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107388:	5b                   	pop    %ebx
80107389:	5e                   	pop    %esi
8010738a:	5f                   	pop    %edi
8010738b:	5d                   	pop    %ebp
8010738c:	c3                   	ret    
8010738d:	8d 76 00             	lea    0x0(%esi),%esi
80107390:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107393:	31 c0                	xor    %eax,%eax
}
80107395:	5b                   	pop    %ebx
80107396:	5e                   	pop    %esi
80107397:	5f                   	pop    %edi
80107398:	5d                   	pop    %ebp
80107399:	c3                   	ret    
      panic("remap");
8010739a:	83 ec 0c             	sub    $0xc,%esp
8010739d:	68 9c 88 10 80       	push   $0x8010889c
801073a2:	e8 d9 8f ff ff       	call   80100380 <panic>
801073a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801073ae:	66 90                	xchg   %ax,%ax

801073b0 <seginit>:
{
801073b0:	55                   	push   %ebp
801073b1:	89 e5                	mov    %esp,%ebp
801073b3:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
801073b6:	e8 f5 c5 ff ff       	call   801039b0 <cpuid>
  pd[0] = size-1;
801073bb:	ba 2f 00 00 00       	mov    $0x2f,%edx
801073c0:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801073c6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801073ca:	c7 80 18 28 11 80 ff 	movl   $0xffff,-0x7feed7e8(%eax)
801073d1:	ff 00 00 
801073d4:	c7 80 1c 28 11 80 00 	movl   $0xcf9a00,-0x7feed7e4(%eax)
801073db:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801073de:	c7 80 20 28 11 80 ff 	movl   $0xffff,-0x7feed7e0(%eax)
801073e5:	ff 00 00 
801073e8:	c7 80 24 28 11 80 00 	movl   $0xcf9200,-0x7feed7dc(%eax)
801073ef:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801073f2:	c7 80 28 28 11 80 ff 	movl   $0xffff,-0x7feed7d8(%eax)
801073f9:	ff 00 00 
801073fc:	c7 80 2c 28 11 80 00 	movl   $0xcffa00,-0x7feed7d4(%eax)
80107403:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107406:	c7 80 30 28 11 80 ff 	movl   $0xffff,-0x7feed7d0(%eax)
8010740d:	ff 00 00 
80107410:	c7 80 34 28 11 80 00 	movl   $0xcff200,-0x7feed7cc(%eax)
80107417:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
8010741a:	05 10 28 11 80       	add    $0x80112810,%eax
  pd[1] = (uint)p;
8010741f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80107423:	c1 e8 10             	shr    $0x10,%eax
80107426:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010742a:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010742d:	0f 01 10             	lgdtl  (%eax)
}
80107430:	c9                   	leave  
80107431:	c3                   	ret    
80107432:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107440 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107440:	a1 24 5c 11 80       	mov    0x80115c24,%eax
80107445:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010744a:	0f 22 d8             	mov    %eax,%cr3
}
8010744d:	c3                   	ret    
8010744e:	66 90                	xchg   %ax,%ax

80107450 <switchuvm>:
{
80107450:	55                   	push   %ebp
80107451:	89 e5                	mov    %esp,%ebp
80107453:	57                   	push   %edi
80107454:	56                   	push   %esi
80107455:	53                   	push   %ebx
80107456:	83 ec 1c             	sub    $0x1c,%esp
80107459:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
8010745c:	85 f6                	test   %esi,%esi
8010745e:	0f 84 cb 00 00 00    	je     8010752f <switchuvm+0xdf>
  if(p->kstack == 0)
80107464:	8b 46 08             	mov    0x8(%esi),%eax
80107467:	85 c0                	test   %eax,%eax
80107469:	0f 84 da 00 00 00    	je     80107549 <switchuvm+0xf9>
  if(p->pgdir == 0)
8010746f:	8b 46 04             	mov    0x4(%esi),%eax
80107472:	85 c0                	test   %eax,%eax
80107474:	0f 84 c2 00 00 00    	je     8010753c <switchuvm+0xec>
  pushcli();
8010747a:	e8 91 d7 ff ff       	call   80104c10 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010747f:	e8 cc c4 ff ff       	call   80103950 <mycpu>
80107484:	89 c3                	mov    %eax,%ebx
80107486:	e8 c5 c4 ff ff       	call   80103950 <mycpu>
8010748b:	89 c7                	mov    %eax,%edi
8010748d:	e8 be c4 ff ff       	call   80103950 <mycpu>
80107492:	83 c7 08             	add    $0x8,%edi
80107495:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107498:	e8 b3 c4 ff ff       	call   80103950 <mycpu>
8010749d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801074a0:	ba 67 00 00 00       	mov    $0x67,%edx
801074a5:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801074ac:	83 c0 08             	add    $0x8,%eax
801074af:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801074b6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801074bb:	83 c1 08             	add    $0x8,%ecx
801074be:	c1 e8 18             	shr    $0x18,%eax
801074c1:	c1 e9 10             	shr    $0x10,%ecx
801074c4:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
801074ca:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801074d0:	b9 99 40 00 00       	mov    $0x4099,%ecx
801074d5:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801074dc:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
801074e1:	e8 6a c4 ff ff       	call   80103950 <mycpu>
801074e6:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801074ed:	e8 5e c4 ff ff       	call   80103950 <mycpu>
801074f2:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801074f6:	8b 5e 08             	mov    0x8(%esi),%ebx
801074f9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801074ff:	e8 4c c4 ff ff       	call   80103950 <mycpu>
80107504:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107507:	e8 44 c4 ff ff       	call   80103950 <mycpu>
8010750c:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80107510:	b8 28 00 00 00       	mov    $0x28,%eax
80107515:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107518:	8b 46 04             	mov    0x4(%esi),%eax
8010751b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107520:	0f 22 d8             	mov    %eax,%cr3
}
80107523:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107526:	5b                   	pop    %ebx
80107527:	5e                   	pop    %esi
80107528:	5f                   	pop    %edi
80107529:	5d                   	pop    %ebp
  popcli();
8010752a:	e9 31 d7 ff ff       	jmp    80104c60 <popcli>
    panic("switchuvm: no process");
8010752f:	83 ec 0c             	sub    $0xc,%esp
80107532:	68 a2 88 10 80       	push   $0x801088a2
80107537:	e8 44 8e ff ff       	call   80100380 <panic>
    panic("switchuvm: no pgdir");
8010753c:	83 ec 0c             	sub    $0xc,%esp
8010753f:	68 cd 88 10 80       	push   $0x801088cd
80107544:	e8 37 8e ff ff       	call   80100380 <panic>
    panic("switchuvm: no kstack");
80107549:	83 ec 0c             	sub    $0xc,%esp
8010754c:	68 b8 88 10 80       	push   $0x801088b8
80107551:	e8 2a 8e ff ff       	call   80100380 <panic>
80107556:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010755d:	8d 76 00             	lea    0x0(%esi),%esi

80107560 <inituvm>:
{
80107560:	55                   	push   %ebp
80107561:	89 e5                	mov    %esp,%ebp
80107563:	57                   	push   %edi
80107564:	56                   	push   %esi
80107565:	53                   	push   %ebx
80107566:	83 ec 1c             	sub    $0x1c,%esp
80107569:	8b 45 0c             	mov    0xc(%ebp),%eax
8010756c:	8b 75 10             	mov    0x10(%ebp),%esi
8010756f:	8b 7d 08             	mov    0x8(%ebp),%edi
80107572:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
80107575:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010757b:	77 4b                	ja     801075c8 <inituvm+0x68>
  mem = kalloc();
8010757d:	e8 fe b0 ff ff       	call   80102680 <kalloc>
  memset(mem, 0, PGSIZE);
80107582:	83 ec 04             	sub    $0x4,%esp
80107585:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
8010758a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010758c:	6a 00                	push   $0x0
8010758e:	50                   	push   %eax
8010758f:	e8 8c d8 ff ff       	call   80104e20 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107594:	58                   	pop    %eax
80107595:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010759b:	5a                   	pop    %edx
8010759c:	6a 06                	push   $0x6
8010759e:	b9 00 10 00 00       	mov    $0x1000,%ecx
801075a3:	31 d2                	xor    %edx,%edx
801075a5:	50                   	push   %eax
801075a6:	89 f8                	mov    %edi,%eax
801075a8:	e8 13 fd ff ff       	call   801072c0 <mappages>
  memmove(mem, init, sz);
801075ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801075b0:	89 75 10             	mov    %esi,0x10(%ebp)
801075b3:	83 c4 10             	add    $0x10,%esp
801075b6:	89 5d 08             	mov    %ebx,0x8(%ebp)
801075b9:	89 45 0c             	mov    %eax,0xc(%ebp)
}
801075bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801075bf:	5b                   	pop    %ebx
801075c0:	5e                   	pop    %esi
801075c1:	5f                   	pop    %edi
801075c2:	5d                   	pop    %ebp
  memmove(mem, init, sz);
801075c3:	e9 f8 d8 ff ff       	jmp    80104ec0 <memmove>
    panic("inituvm: more than a page");
801075c8:	83 ec 0c             	sub    $0xc,%esp
801075cb:	68 e1 88 10 80       	push   $0x801088e1
801075d0:	e8 ab 8d ff ff       	call   80100380 <panic>
801075d5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801075dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801075e0 <loaduvm>:
{
801075e0:	55                   	push   %ebp
801075e1:	89 e5                	mov    %esp,%ebp
801075e3:	57                   	push   %edi
801075e4:	56                   	push   %esi
801075e5:	53                   	push   %ebx
801075e6:	83 ec 1c             	sub    $0x1c,%esp
801075e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801075ec:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
801075ef:	a9 ff 0f 00 00       	test   $0xfff,%eax
801075f4:	0f 85 bb 00 00 00    	jne    801076b5 <loaduvm+0xd5>
  for(i = 0; i < sz; i += PGSIZE){
801075fa:	01 f0                	add    %esi,%eax
801075fc:	89 f3                	mov    %esi,%ebx
801075fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107601:	8b 45 14             	mov    0x14(%ebp),%eax
80107604:	01 f0                	add    %esi,%eax
80107606:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
80107609:	85 f6                	test   %esi,%esi
8010760b:	0f 84 87 00 00 00    	je     80107698 <loaduvm+0xb8>
80107611:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  pde = &pgdir[PDX(va)];
80107618:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  if(*pde & PTE_P){
8010761b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010761e:	29 d8                	sub    %ebx,%eax
  pde = &pgdir[PDX(va)];
80107620:	89 c2                	mov    %eax,%edx
80107622:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
80107625:	8b 14 91             	mov    (%ecx,%edx,4),%edx
80107628:	f6 c2 01             	test   $0x1,%dl
8010762b:	75 13                	jne    80107640 <loaduvm+0x60>
      panic("loaduvm: address should exist");
8010762d:	83 ec 0c             	sub    $0xc,%esp
80107630:	68 fb 88 10 80       	push   $0x801088fb
80107635:	e8 46 8d ff ff       	call   80100380 <panic>
8010763a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107640:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107643:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107649:	25 fc 0f 00 00       	and    $0xffc,%eax
8010764e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107655:	85 c0                	test   %eax,%eax
80107657:	74 d4                	je     8010762d <loaduvm+0x4d>
    pa = PTE_ADDR(*pte);
80107659:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010765b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
8010765e:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80107663:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80107668:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
8010766e:	0f 46 fb             	cmovbe %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107671:	29 d9                	sub    %ebx,%ecx
80107673:	05 00 00 00 80       	add    $0x80000000,%eax
80107678:	57                   	push   %edi
80107679:	51                   	push   %ecx
8010767a:	50                   	push   %eax
8010767b:	ff 75 10             	push   0x10(%ebp)
8010767e:	e8 0d a4 ff ff       	call   80101a90 <readi>
80107683:	83 c4 10             	add    $0x10,%esp
80107686:	39 f8                	cmp    %edi,%eax
80107688:	75 1e                	jne    801076a8 <loaduvm+0xc8>
  for(i = 0; i < sz; i += PGSIZE){
8010768a:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
80107690:	89 f0                	mov    %esi,%eax
80107692:	29 d8                	sub    %ebx,%eax
80107694:	39 c6                	cmp    %eax,%esi
80107696:	77 80                	ja     80107618 <loaduvm+0x38>
}
80107698:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010769b:	31 c0                	xor    %eax,%eax
}
8010769d:	5b                   	pop    %ebx
8010769e:	5e                   	pop    %esi
8010769f:	5f                   	pop    %edi
801076a0:	5d                   	pop    %ebp
801076a1:	c3                   	ret    
801076a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801076a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801076ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801076b0:	5b                   	pop    %ebx
801076b1:	5e                   	pop    %esi
801076b2:	5f                   	pop    %edi
801076b3:	5d                   	pop    %ebp
801076b4:	c3                   	ret    
    panic("loaduvm: addr must be page aligned");
801076b5:	83 ec 0c             	sub    $0xc,%esp
801076b8:	68 9c 89 10 80       	push   $0x8010899c
801076bd:	e8 be 8c ff ff       	call   80100380 <panic>
801076c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801076c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801076d0 <allocuvm>:
{
801076d0:	55                   	push   %ebp
801076d1:	89 e5                	mov    %esp,%ebp
801076d3:	57                   	push   %edi
801076d4:	56                   	push   %esi
801076d5:	53                   	push   %ebx
801076d6:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
801076d9:	8b 45 10             	mov    0x10(%ebp),%eax
{
801076dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
801076df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801076e2:	85 c0                	test   %eax,%eax
801076e4:	0f 88 b6 00 00 00    	js     801077a0 <allocuvm+0xd0>
  if(newsz < oldsz)
801076ea:	3b 45 0c             	cmp    0xc(%ebp),%eax
    return oldsz;
801076ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(newsz < oldsz)
801076f0:	0f 82 9a 00 00 00    	jb     80107790 <allocuvm+0xc0>
  a = PGROUNDUP(oldsz);
801076f6:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801076fc:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80107702:	39 75 10             	cmp    %esi,0x10(%ebp)
80107705:	77 44                	ja     8010774b <allocuvm+0x7b>
80107707:	e9 87 00 00 00       	jmp    80107793 <allocuvm+0xc3>
8010770c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    memset(mem, 0, PGSIZE);
80107710:	83 ec 04             	sub    $0x4,%esp
80107713:	68 00 10 00 00       	push   $0x1000
80107718:	6a 00                	push   $0x0
8010771a:	50                   	push   %eax
8010771b:	e8 00 d7 ff ff       	call   80104e20 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107720:	58                   	pop    %eax
80107721:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107727:	5a                   	pop    %edx
80107728:	6a 06                	push   $0x6
8010772a:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010772f:	89 f2                	mov    %esi,%edx
80107731:	50                   	push   %eax
80107732:	89 f8                	mov    %edi,%eax
80107734:	e8 87 fb ff ff       	call   801072c0 <mappages>
80107739:	83 c4 10             	add    $0x10,%esp
8010773c:	85 c0                	test   %eax,%eax
8010773e:	78 78                	js     801077b8 <allocuvm+0xe8>
  for(; a < newsz; a += PGSIZE){
80107740:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107746:	39 75 10             	cmp    %esi,0x10(%ebp)
80107749:	76 48                	jbe    80107793 <allocuvm+0xc3>
    mem = kalloc();
8010774b:	e8 30 af ff ff       	call   80102680 <kalloc>
80107750:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80107752:	85 c0                	test   %eax,%eax
80107754:	75 ba                	jne    80107710 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80107756:	83 ec 0c             	sub    $0xc,%esp
80107759:	68 19 89 10 80       	push   $0x80108919
8010775e:	e8 3d 8f ff ff       	call   801006a0 <cprintf>
  if(newsz >= oldsz)
80107763:	8b 45 0c             	mov    0xc(%ebp),%eax
80107766:	83 c4 10             	add    $0x10,%esp
80107769:	39 45 10             	cmp    %eax,0x10(%ebp)
8010776c:	74 32                	je     801077a0 <allocuvm+0xd0>
8010776e:	8b 55 10             	mov    0x10(%ebp),%edx
80107771:	89 c1                	mov    %eax,%ecx
80107773:	89 f8                	mov    %edi,%eax
80107775:	e8 96 fa ff ff       	call   80107210 <deallocuvm.part.0>
      return 0;
8010777a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80107781:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107784:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107787:	5b                   	pop    %ebx
80107788:	5e                   	pop    %esi
80107789:	5f                   	pop    %edi
8010778a:	5d                   	pop    %ebp
8010778b:	c3                   	ret    
8010778c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
80107790:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}
80107793:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107796:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107799:	5b                   	pop    %ebx
8010779a:	5e                   	pop    %esi
8010779b:	5f                   	pop    %edi
8010779c:	5d                   	pop    %ebp
8010779d:	c3                   	ret    
8010779e:	66 90                	xchg   %ax,%ax
    return 0;
801077a0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801077a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801077aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801077ad:	5b                   	pop    %ebx
801077ae:	5e                   	pop    %esi
801077af:	5f                   	pop    %edi
801077b0:	5d                   	pop    %ebp
801077b1:	c3                   	ret    
801077b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
801077b8:	83 ec 0c             	sub    $0xc,%esp
801077bb:	68 31 89 10 80       	push   $0x80108931
801077c0:	e8 db 8e ff ff       	call   801006a0 <cprintf>
  if(newsz >= oldsz)
801077c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801077c8:	83 c4 10             	add    $0x10,%esp
801077cb:	39 45 10             	cmp    %eax,0x10(%ebp)
801077ce:	74 0c                	je     801077dc <allocuvm+0x10c>
801077d0:	8b 55 10             	mov    0x10(%ebp),%edx
801077d3:	89 c1                	mov    %eax,%ecx
801077d5:	89 f8                	mov    %edi,%eax
801077d7:	e8 34 fa ff ff       	call   80107210 <deallocuvm.part.0>
      kfree(mem);
801077dc:	83 ec 0c             	sub    $0xc,%esp
801077df:	53                   	push   %ebx
801077e0:	e8 db ac ff ff       	call   801024c0 <kfree>
      return 0;
801077e5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801077ec:	83 c4 10             	add    $0x10,%esp
}
801077ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801077f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801077f5:	5b                   	pop    %ebx
801077f6:	5e                   	pop    %esi
801077f7:	5f                   	pop    %edi
801077f8:	5d                   	pop    %ebp
801077f9:	c3                   	ret    
801077fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107800 <deallocuvm>:
{
80107800:	55                   	push   %ebp
80107801:	89 e5                	mov    %esp,%ebp
80107803:	8b 55 0c             	mov    0xc(%ebp),%edx
80107806:	8b 4d 10             	mov    0x10(%ebp),%ecx
80107809:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
8010780c:	39 d1                	cmp    %edx,%ecx
8010780e:	73 10                	jae    80107820 <deallocuvm+0x20>
}
80107810:	5d                   	pop    %ebp
80107811:	e9 fa f9 ff ff       	jmp    80107210 <deallocuvm.part.0>
80107816:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010781d:	8d 76 00             	lea    0x0(%esi),%esi
80107820:	89 d0                	mov    %edx,%eax
80107822:	5d                   	pop    %ebp
80107823:	c3                   	ret    
80107824:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010782b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010782f:	90                   	nop

80107830 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107830:	55                   	push   %ebp
80107831:	89 e5                	mov    %esp,%ebp
80107833:	57                   	push   %edi
80107834:	56                   	push   %esi
80107835:	53                   	push   %ebx
80107836:	83 ec 0c             	sub    $0xc,%esp
80107839:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010783c:	85 f6                	test   %esi,%esi
8010783e:	74 59                	je     80107899 <freevm+0x69>
  if(newsz >= oldsz)
80107840:	31 c9                	xor    %ecx,%ecx
80107842:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107847:	89 f0                	mov    %esi,%eax
80107849:	89 f3                	mov    %esi,%ebx
8010784b:	e8 c0 f9 ff ff       	call   80107210 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107850:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107856:	eb 0f                	jmp    80107867 <freevm+0x37>
80107858:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010785f:	90                   	nop
80107860:	83 c3 04             	add    $0x4,%ebx
80107863:	39 df                	cmp    %ebx,%edi
80107865:	74 23                	je     8010788a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80107867:	8b 03                	mov    (%ebx),%eax
80107869:	a8 01                	test   $0x1,%al
8010786b:	74 f3                	je     80107860 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010786d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107872:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107875:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107878:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010787d:	50                   	push   %eax
8010787e:	e8 3d ac ff ff       	call   801024c0 <kfree>
80107883:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107886:	39 df                	cmp    %ebx,%edi
80107888:	75 dd                	jne    80107867 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010788a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010788d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107890:	5b                   	pop    %ebx
80107891:	5e                   	pop    %esi
80107892:	5f                   	pop    %edi
80107893:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107894:	e9 27 ac ff ff       	jmp    801024c0 <kfree>
    panic("freevm: no pgdir");
80107899:	83 ec 0c             	sub    $0xc,%esp
8010789c:	68 4d 89 10 80       	push   $0x8010894d
801078a1:	e8 da 8a ff ff       	call   80100380 <panic>
801078a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801078ad:	8d 76 00             	lea    0x0(%esi),%esi

801078b0 <setupkvm>:
{
801078b0:	55                   	push   %ebp
801078b1:	89 e5                	mov    %esp,%ebp
801078b3:	56                   	push   %esi
801078b4:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801078b5:	e8 c6 ad ff ff       	call   80102680 <kalloc>
801078ba:	89 c6                	mov    %eax,%esi
801078bc:	85 c0                	test   %eax,%eax
801078be:	74 42                	je     80107902 <setupkvm+0x52>
  memset(pgdir, 0, PGSIZE);
801078c0:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078c3:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
801078c8:	68 00 10 00 00       	push   $0x1000
801078cd:	6a 00                	push   $0x0
801078cf:	50                   	push   %eax
801078d0:	e8 4b d5 ff ff       	call   80104e20 <memset>
801078d5:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
801078d8:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801078db:	83 ec 08             	sub    $0x8,%esp
801078de:	8b 4b 08             	mov    0x8(%ebx),%ecx
801078e1:	ff 73 0c             	push   0xc(%ebx)
801078e4:	8b 13                	mov    (%ebx),%edx
801078e6:	50                   	push   %eax
801078e7:	29 c1                	sub    %eax,%ecx
801078e9:	89 f0                	mov    %esi,%eax
801078eb:	e8 d0 f9 ff ff       	call   801072c0 <mappages>
801078f0:	83 c4 10             	add    $0x10,%esp
801078f3:	85 c0                	test   %eax,%eax
801078f5:	78 19                	js     80107910 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078f7:	83 c3 10             	add    $0x10,%ebx
801078fa:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80107900:	75 d6                	jne    801078d8 <setupkvm+0x28>
}
80107902:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107905:	89 f0                	mov    %esi,%eax
80107907:	5b                   	pop    %ebx
80107908:	5e                   	pop    %esi
80107909:	5d                   	pop    %ebp
8010790a:	c3                   	ret    
8010790b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010790f:	90                   	nop
      freevm(pgdir);
80107910:	83 ec 0c             	sub    $0xc,%esp
80107913:	56                   	push   %esi
      return 0;
80107914:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
80107916:	e8 15 ff ff ff       	call   80107830 <freevm>
      return 0;
8010791b:	83 c4 10             	add    $0x10,%esp
}
8010791e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107921:	89 f0                	mov    %esi,%eax
80107923:	5b                   	pop    %ebx
80107924:	5e                   	pop    %esi
80107925:	5d                   	pop    %ebp
80107926:	c3                   	ret    
80107927:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010792e:	66 90                	xchg   %ax,%ax

80107930 <kvmalloc>:
{
80107930:	55                   	push   %ebp
80107931:	89 e5                	mov    %esp,%ebp
80107933:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107936:	e8 75 ff ff ff       	call   801078b0 <setupkvm>
8010793b:	a3 24 5c 11 80       	mov    %eax,0x80115c24
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107940:	05 00 00 00 80       	add    $0x80000000,%eax
80107945:	0f 22 d8             	mov    %eax,%cr3
}
80107948:	c9                   	leave  
80107949:	c3                   	ret    
8010794a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107950 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107950:	55                   	push   %ebp
80107951:	89 e5                	mov    %esp,%ebp
80107953:	83 ec 08             	sub    $0x8,%esp
80107956:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107959:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
8010795c:	89 c1                	mov    %eax,%ecx
8010795e:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
80107961:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107964:	f6 c2 01             	test   $0x1,%dl
80107967:	75 17                	jne    80107980 <clearpteu+0x30>
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
80107969:	83 ec 0c             	sub    $0xc,%esp
8010796c:	68 5e 89 10 80       	push   $0x8010895e
80107971:	e8 0a 8a ff ff       	call   80100380 <panic>
80107976:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010797d:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107980:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107983:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107989:	25 fc 0f 00 00       	and    $0xffc,%eax
8010798e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
  if(pte == 0)
80107995:	85 c0                	test   %eax,%eax
80107997:	74 d0                	je     80107969 <clearpteu+0x19>
  *pte &= ~PTE_U;
80107999:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010799c:	c9                   	leave  
8010799d:	c3                   	ret    
8010799e:	66 90                	xchg   %ax,%ax

801079a0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801079a0:	55                   	push   %ebp
801079a1:	89 e5                	mov    %esp,%ebp
801079a3:	57                   	push   %edi
801079a4:	56                   	push   %esi
801079a5:	53                   	push   %ebx
801079a6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801079a9:	e8 02 ff ff ff       	call   801078b0 <setupkvm>
801079ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
801079b1:	85 c0                	test   %eax,%eax
801079b3:	0f 84 bd 00 00 00    	je     80107a76 <copyuvm+0xd6>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801079b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801079bc:	85 c9                	test   %ecx,%ecx
801079be:	0f 84 b2 00 00 00    	je     80107a76 <copyuvm+0xd6>
801079c4:	31 f6                	xor    %esi,%esi
801079c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801079cd:	8d 76 00             	lea    0x0(%esi),%esi
  if(*pde & PTE_P){
801079d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  pde = &pgdir[PDX(va)];
801079d3:	89 f0                	mov    %esi,%eax
801079d5:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
801079d8:	8b 04 81             	mov    (%ecx,%eax,4),%eax
801079db:	a8 01                	test   $0x1,%al
801079dd:	75 11                	jne    801079f0 <copyuvm+0x50>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
801079df:	83 ec 0c             	sub    $0xc,%esp
801079e2:	68 68 89 10 80       	push   $0x80108968
801079e7:	e8 94 89 ff ff       	call   80100380 <panic>
801079ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return &pgtab[PTX(va)];
801079f0:	89 f2                	mov    %esi,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801079f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
801079f7:	c1 ea 0a             	shr    $0xa,%edx
801079fa:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107a00:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107a07:	85 c0                	test   %eax,%eax
80107a09:	74 d4                	je     801079df <copyuvm+0x3f>
    if(!(*pte & PTE_P))
80107a0b:	8b 00                	mov    (%eax),%eax
80107a0d:	a8 01                	test   $0x1,%al
80107a0f:	0f 84 9f 00 00 00    	je     80107ab4 <copyuvm+0x114>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80107a15:	89 c7                	mov    %eax,%edi
    flags = PTE_FLAGS(*pte);
80107a17:	25 ff 0f 00 00       	and    $0xfff,%eax
80107a1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
80107a1f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
80107a25:	e8 56 ac ff ff       	call   80102680 <kalloc>
80107a2a:	89 c3                	mov    %eax,%ebx
80107a2c:	85 c0                	test   %eax,%eax
80107a2e:	74 64                	je     80107a94 <copyuvm+0xf4>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107a30:	83 ec 04             	sub    $0x4,%esp
80107a33:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80107a39:	68 00 10 00 00       	push   $0x1000
80107a3e:	57                   	push   %edi
80107a3f:	50                   	push   %eax
80107a40:	e8 7b d4 ff ff       	call   80104ec0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80107a45:	58                   	pop    %eax
80107a46:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107a4c:	5a                   	pop    %edx
80107a4d:	ff 75 e4             	push   -0x1c(%ebp)
80107a50:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107a55:	89 f2                	mov    %esi,%edx
80107a57:	50                   	push   %eax
80107a58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a5b:	e8 60 f8 ff ff       	call   801072c0 <mappages>
80107a60:	83 c4 10             	add    $0x10,%esp
80107a63:	85 c0                	test   %eax,%eax
80107a65:	78 21                	js     80107a88 <copyuvm+0xe8>
  for(i = 0; i < sz; i += PGSIZE){
80107a67:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107a6d:	39 75 0c             	cmp    %esi,0xc(%ebp)
80107a70:	0f 87 5a ff ff ff    	ja     801079d0 <copyuvm+0x30>
  return d;

bad:
  freevm(d);
  return 0;
}
80107a76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107a7c:	5b                   	pop    %ebx
80107a7d:	5e                   	pop    %esi
80107a7e:	5f                   	pop    %edi
80107a7f:	5d                   	pop    %ebp
80107a80:	c3                   	ret    
80107a81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      kfree(mem);
80107a88:	83 ec 0c             	sub    $0xc,%esp
80107a8b:	53                   	push   %ebx
80107a8c:	e8 2f aa ff ff       	call   801024c0 <kfree>
      goto bad;
80107a91:	83 c4 10             	add    $0x10,%esp
  freevm(d);
80107a94:	83 ec 0c             	sub    $0xc,%esp
80107a97:	ff 75 e0             	push   -0x20(%ebp)
80107a9a:	e8 91 fd ff ff       	call   80107830 <freevm>
  return 0;
80107a9f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80107aa6:	83 c4 10             	add    $0x10,%esp
}
80107aa9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107aac:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107aaf:	5b                   	pop    %ebx
80107ab0:	5e                   	pop    %esi
80107ab1:	5f                   	pop    %edi
80107ab2:	5d                   	pop    %ebp
80107ab3:	c3                   	ret    
      panic("copyuvm: page not present");
80107ab4:	83 ec 0c             	sub    $0xc,%esp
80107ab7:	68 82 89 10 80       	push   $0x80108982
80107abc:	e8 bf 88 ff ff       	call   80100380 <panic>
80107ac1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107ac8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107acf:	90                   	nop

80107ad0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107ad0:	55                   	push   %ebp
80107ad1:	89 e5                	mov    %esp,%ebp
80107ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107ad6:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107ad9:	89 c1                	mov    %eax,%ecx
80107adb:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
80107ade:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107ae1:	f6 c2 01             	test   $0x1,%dl
80107ae4:	0f 84 00 01 00 00    	je     80107bea <uva2ka.cold>
  return &pgtab[PTX(va)];
80107aea:	c1 e8 0c             	shr    $0xc,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107aed:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107af3:	5d                   	pop    %ebp
  return &pgtab[PTX(va)];
80107af4:	25 ff 03 00 00       	and    $0x3ff,%eax
  if((*pte & PTE_P) == 0)
80107af9:	8b 84 82 00 00 00 80 	mov    -0x80000000(%edx,%eax,4),%eax
  if((*pte & PTE_U) == 0)
80107b00:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107b02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80107b07:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107b0a:	05 00 00 00 80       	add    $0x80000000,%eax
80107b0f:	83 fa 05             	cmp    $0x5,%edx
80107b12:	ba 00 00 00 00       	mov    $0x0,%edx
80107b17:	0f 45 c2             	cmovne %edx,%eax
}
80107b1a:	c3                   	ret    
80107b1b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107b1f:	90                   	nop

80107b20 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107b20:	55                   	push   %ebp
80107b21:	89 e5                	mov    %esp,%ebp
80107b23:	57                   	push   %edi
80107b24:	56                   	push   %esi
80107b25:	53                   	push   %ebx
80107b26:	83 ec 0c             	sub    $0xc,%esp
80107b29:	8b 75 14             	mov    0x14(%ebp),%esi
80107b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b2f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107b32:	85 f6                	test   %esi,%esi
80107b34:	75 51                	jne    80107b87 <copyout+0x67>
80107b36:	e9 a5 00 00 00       	jmp    80107be0 <copyout+0xc0>
80107b3b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107b3f:	90                   	nop
  return (char*)P2V(PTE_ADDR(*pte));
80107b40:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80107b46:	8d 8b 00 00 00 80    	lea    -0x80000000(%ebx),%ecx
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
80107b4c:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80107b52:	74 75                	je     80107bc9 <copyout+0xa9>
      return -1;
    n = PGSIZE - (va - va0);
80107b54:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107b56:	89 55 10             	mov    %edx,0x10(%ebp)
    n = PGSIZE - (va - va0);
80107b59:	29 c3                	sub    %eax,%ebx
80107b5b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107b61:	39 f3                	cmp    %esi,%ebx
80107b63:	0f 47 de             	cmova  %esi,%ebx
    memmove(pa0 + (va - va0), buf, n);
80107b66:	29 f8                	sub    %edi,%eax
80107b68:	83 ec 04             	sub    $0x4,%esp
80107b6b:	01 c1                	add    %eax,%ecx
80107b6d:	53                   	push   %ebx
80107b6e:	52                   	push   %edx
80107b6f:	51                   	push   %ecx
80107b70:	e8 4b d3 ff ff       	call   80104ec0 <memmove>
    len -= n;
    buf += n;
80107b75:	8b 55 10             	mov    0x10(%ebp),%edx
    va = va0 + PGSIZE;
80107b78:	8d 87 00 10 00 00    	lea    0x1000(%edi),%eax
  while(len > 0){
80107b7e:	83 c4 10             	add    $0x10,%esp
    buf += n;
80107b81:	01 da                	add    %ebx,%edx
  while(len > 0){
80107b83:	29 de                	sub    %ebx,%esi
80107b85:	74 59                	je     80107be0 <copyout+0xc0>
  if(*pde & PTE_P){
80107b87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pde = &pgdir[PDX(va)];
80107b8a:	89 c1                	mov    %eax,%ecx
    va0 = (uint)PGROUNDDOWN(va);
80107b8c:	89 c7                	mov    %eax,%edi
  pde = &pgdir[PDX(va)];
80107b8e:	c1 e9 16             	shr    $0x16,%ecx
    va0 = (uint)PGROUNDDOWN(va);
80107b91:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if(*pde & PTE_P){
80107b97:	8b 0c 8b             	mov    (%ebx,%ecx,4),%ecx
80107b9a:	f6 c1 01             	test   $0x1,%cl
80107b9d:	0f 84 4e 00 00 00    	je     80107bf1 <copyout.cold>
  return &pgtab[PTX(va)];
80107ba3:	89 fb                	mov    %edi,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107ba5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
80107bab:	c1 eb 0c             	shr    $0xc,%ebx
80107bae:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  if((*pte & PTE_P) == 0)
80107bb4:	8b 9c 99 00 00 00 80 	mov    -0x80000000(%ecx,%ebx,4),%ebx
  if((*pte & PTE_U) == 0)
80107bbb:	89 d9                	mov    %ebx,%ecx
80107bbd:	83 e1 05             	and    $0x5,%ecx
80107bc0:	83 f9 05             	cmp    $0x5,%ecx
80107bc3:	0f 84 77 ff ff ff    	je     80107b40 <copyout+0x20>
  }
  return 0;
}
80107bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107bd1:	5b                   	pop    %ebx
80107bd2:	5e                   	pop    %esi
80107bd3:	5f                   	pop    %edi
80107bd4:	5d                   	pop    %ebp
80107bd5:	c3                   	ret    
80107bd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107bdd:	8d 76 00             	lea    0x0(%esi),%esi
80107be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107be3:	31 c0                	xor    %eax,%eax
}
80107be5:	5b                   	pop    %ebx
80107be6:	5e                   	pop    %esi
80107be7:	5f                   	pop    %edi
80107be8:	5d                   	pop    %ebp
80107be9:	c3                   	ret    

80107bea <uva2ka.cold>:
  if((*pte & PTE_P) == 0)
80107bea:	a1 00 00 00 00       	mov    0x0,%eax
80107bef:	0f 0b                	ud2    

80107bf1 <copyout.cold>:
80107bf1:	a1 00 00 00 00       	mov    0x0,%eax
80107bf6:	0f 0b                	ud2    
80107bf8:	66 90                	xchg   %ax,%ax
80107bfa:	66 90                	xchg   %ax,%ax
80107bfc:	66 90                	xchg   %ax,%ax
80107bfe:	66 90                	xchg   %ax,%ax

80107c00 <myfunction>:
#include "defs.h"

// Simple system call
int
myfunction(char *str)
{
80107c00:	55                   	push   %ebp
80107c01:	89 e5                	mov    %esp,%ebp
80107c03:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n",str);
80107c06:	ff 75 08             	push   0x8(%ebp)
80107c09:	68 bf 89 10 80       	push   $0x801089bf
80107c0e:	e8 8d 8a ff ff       	call   801006a0 <cprintf>
	return 0xABCDABCD;
}
80107c13:	b8 cd ab cd ab       	mov    $0xabcdabcd,%eax
80107c18:	c9                   	leave  
80107c19:	c3                   	ret    
80107c1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107c20 <sys_myfunction>:
//Wrapper for my_syscall
int
sys_myfunction(void)
{
80107c20:	55                   	push   %ebp
80107c21:	89 e5                	mov    %esp,%ebp
80107c23:	83 ec 20             	sub    $0x20,%esp
char *str;
//Decode argument using argstr
if (argstr(0, &str) < 0)
80107c26:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107c29:	50                   	push   %eax
80107c2a:	6a 00                	push   $0x0
80107c2c:	e8 6f d5 ff ff       	call   801051a0 <argstr>
80107c31:	83 c4 10             	add    $0x10,%esp
80107c34:	89 c2                	mov    %eax,%edx
80107c36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c3b:	85 d2                	test   %edx,%edx
80107c3d:	78 18                	js     80107c57 <sys_myfunction+0x37>
	cprintf("%s\n",str);
80107c3f:	83 ec 08             	sub    $0x8,%esp
80107c42:	ff 75 f4             	push   -0xc(%ebp)
80107c45:	68 bf 89 10 80       	push   $0x801089bf
80107c4a:	e8 51 8a ff ff       	call   801006a0 <cprintf>
	return -1;
return myfunction(str);
80107c4f:	83 c4 10             	add    $0x10,%esp
80107c52:	b8 cd ab cd ab       	mov    $0xabcdabcd,%eax
}
80107c57:	c9                   	leave  
80107c58:	c3                   	ret    
80107c59:	66 90                	xchg   %ax,%ax
80107c5b:	66 90                	xchg   %ax,%ax
80107c5d:	66 90                	xchg   %ax,%ax
80107c5f:	90                   	nop

80107c60 <initQueue>:
#include "queue.h"


void
initQueue(struct Queue *queue)
{
80107c60:	55                   	push   %ebp
80107c61:	89 e5                	mov    %esp,%ebp
80107c63:	8b 55 08             	mov    0x8(%ebp),%edx
    queue->front = 0;
80107c66:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    queue->rear = 0;
80107c6c:	8d 42 0c             	lea    0xc(%edx),%eax
80107c6f:	81 c2 10 01 00 00    	add    $0x110,%edx
80107c75:	c7 82 f4 fe ff ff 00 	movl   $0x0,-0x10c(%edx)
80107c7c:	00 00 00 
    queue->count = 0;
80107c7f:	c7 82 f8 fe ff ff 00 	movl   $0x0,-0x108(%edx)
80107c86:	00 00 00 
    for(int i = 0; i < NPROC + 1; i++){
80107c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        queue->q[i] = NULL; // pointer 모두 NULL로 초기화
80107c90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for(int i = 0; i < NPROC + 1; i++){
80107c96:	83 c0 04             	add    $0x4,%eax
80107c99:	39 d0                	cmp    %edx,%eax
80107c9b:	75 f3                	jne    80107c90 <initQueue+0x30>
    }
}
80107c9d:	5d                   	pop    %ebp
80107c9e:	c3                   	ret    
80107c9f:	90                   	nop

80107ca0 <isEmpty>:

int
isEmpty(struct Queue *queue)
{
80107ca0:	55                   	push   %ebp
80107ca1:	89 e5                	mov    %esp,%ebp
80107ca3:	8b 45 08             	mov    0x8(%ebp),%eax
    if (queue->front == queue->rear)
        return 1;
    return 0;
}
80107ca6:	5d                   	pop    %ebp
    if (queue->front == queue->rear)
80107ca7:	8b 50 04             	mov    0x4(%eax),%edx
80107caa:	39 10                	cmp    %edx,(%eax)
80107cac:	0f 94 c0             	sete   %al
80107caf:	0f b6 c0             	movzbl %al,%eax
}
80107cb2:	c3                   	ret    
80107cb3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107cc0 <isFull>:

int
isFull(struct Queue *queue)
{
80107cc0:	55                   	push   %ebp
    if ((queue->rear + 1) % (NPROC + 1) == queue->front)
80107cc1:	ba 7f e0 07 7e       	mov    $0x7e07e07f,%edx
{
80107cc6:	89 e5                	mov    %esp,%ebp
80107cc8:	53                   	push   %ebx
80107cc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if ((queue->rear + 1) % (NPROC + 1) == queue->front)
80107ccc:	8b 43 04             	mov    0x4(%ebx),%eax
80107ccf:	8d 48 01             	lea    0x1(%eax),%ecx
80107cd2:	89 c8                	mov    %ecx,%eax
80107cd4:	f7 ea                	imul   %edx
80107cd6:	89 c8                	mov    %ecx,%eax
80107cd8:	c1 f8 1f             	sar    $0x1f,%eax
80107cdb:	c1 fa 05             	sar    $0x5,%edx
80107cde:	29 c2                	sub    %eax,%edx
80107ce0:	89 d0                	mov    %edx,%eax
80107ce2:	c1 e0 06             	shl    $0x6,%eax
80107ce5:	01 d0                	add    %edx,%eax
80107ce7:	29 c1                	sub    %eax,%ecx
80107ce9:	31 c0                	xor    %eax,%eax
80107ceb:	3b 0b                	cmp    (%ebx),%ecx
        return 1;
    return 0;
}
80107ced:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107cf0:	c9                   	leave  
    if ((queue->rear + 1) % (NPROC + 1) == queue->front)
80107cf1:	0f 94 c0             	sete   %al
}
80107cf4:	c3                   	ret    
80107cf5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80107d00 <enqueue>:

void
enqueue(struct Queue *queue, struct proc *p)
{
80107d00:	55                   	push   %ebp
    if ((queue->rear + 1) % (NPROC + 1) == queue->front)
80107d01:	ba 7f e0 07 7e       	mov    $0x7e07e07f,%edx
{
80107d06:	89 e5                	mov    %esp,%ebp
80107d08:	53                   	push   %ebx
80107d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
    if ((queue->rear + 1) % (NPROC + 1) == queue->front)
80107d0c:	8b 41 04             	mov    0x4(%ecx),%eax
80107d0f:	8d 58 01             	lea    0x1(%eax),%ebx
80107d12:	89 d8                	mov    %ebx,%eax
80107d14:	f7 ea                	imul   %edx
80107d16:	89 d8                	mov    %ebx,%eax
80107d18:	c1 f8 1f             	sar    $0x1f,%eax
80107d1b:	c1 fa 05             	sar    $0x5,%edx
80107d1e:	29 c2                	sub    %eax,%edx
80107d20:	89 d0                	mov    %edx,%eax
80107d22:	c1 e0 06             	shl    $0x6,%eax
80107d25:	01 d0                	add    %edx,%eax
80107d27:	29 c3                	sub    %eax,%ebx
80107d29:	3b 19                	cmp    (%ecx),%ebx
80107d2b:	74 0e                	je     80107d3b <enqueue+0x3b>
    if(isFull(queue))
        return;
    queue->rear = (queue->rear + 1) % (NPROC + 1);
    queue->q[queue->rear] = p;
80107d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
    queue->rear = (queue->rear + 1) % (NPROC + 1);
80107d30:	89 59 04             	mov    %ebx,0x4(%ecx)
    queue->q[queue->rear] = p;
80107d33:	89 44 99 0c          	mov    %eax,0xc(%ecx,%ebx,4)
    queue->count++;
80107d37:	83 41 08 01          	addl   $0x1,0x8(%ecx)
}
80107d3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d3e:	c9                   	leave  
80107d3f:	c3                   	ret    

80107d40 <dequeue>:

struct proc *
dequeue(struct Queue *queue)
{
80107d40:	55                   	push   %ebp
80107d41:	31 c0                	xor    %eax,%eax
80107d43:	89 e5                	mov    %esp,%ebp
80107d45:	53                   	push   %ebx
80107d46:	8b 4d 08             	mov    0x8(%ebp),%ecx
    if (queue->front == queue->rear)
80107d49:	8b 19                	mov    (%ecx),%ebx
80107d4b:	3b 59 04             	cmp    0x4(%ecx),%ebx
80107d4e:	74 29                	je     80107d79 <dequeue+0x39>
    if (isEmpty(queue)) // empty queue
        return NULL;
    queue->front = (queue->front + 1) % (NPROC + 1);
80107d50:	83 c3 01             	add    $0x1,%ebx
80107d53:	ba 7f e0 07 7e       	mov    $0x7e07e07f,%edx
    queue->count--;
80107d58:	83 69 08 01          	subl   $0x1,0x8(%ecx)
    queue->front = (queue->front + 1) % (NPROC + 1);
80107d5c:	89 d8                	mov    %ebx,%eax
80107d5e:	f7 ea                	imul   %edx
80107d60:	89 d8                	mov    %ebx,%eax
80107d62:	c1 f8 1f             	sar    $0x1f,%eax
80107d65:	c1 fa 05             	sar    $0x5,%edx
80107d68:	29 c2                	sub    %eax,%edx
80107d6a:	89 d0                	mov    %edx,%eax
80107d6c:	c1 e0 06             	shl    $0x6,%eax
80107d6f:	01 d0                	add    %edx,%eax
80107d71:	29 c3                	sub    %eax,%ebx
80107d73:	89 19                	mov    %ebx,(%ecx)

    return queue->q[queue->front];
80107d75:	8b 44 99 0c          	mov    0xc(%ecx,%ebx,4),%eax
}
80107d79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d7c:	c9                   	leave  
80107d7d:	c3                   	ret    
80107d7e:	66 90                	xchg   %ax,%ax

80107d80 <top>:

struct proc *
top(struct Queue *queue)
{
80107d80:	55                   	push   %ebp
80107d81:	31 c0                	xor    %eax,%eax
80107d83:	89 e5                	mov    %esp,%ebp
80107d85:	53                   	push   %ebx
80107d86:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (queue->front == queue->rear)
80107d89:	8b 0b                	mov    (%ebx),%ecx
80107d8b:	3b 4b 04             	cmp    0x4(%ebx),%ecx
80107d8e:	74 23                	je     80107db3 <top+0x33>
    if(isEmpty(queue))
        return NULL;
    return queue->q[(queue->front + 1) % (NPROC + 1)];
80107d90:	83 c1 01             	add    $0x1,%ecx
80107d93:	ba 7f e0 07 7e       	mov    $0x7e07e07f,%edx
80107d98:	89 c8                	mov    %ecx,%eax
80107d9a:	f7 ea                	imul   %edx
80107d9c:	89 c8                	mov    %ecx,%eax
80107d9e:	c1 f8 1f             	sar    $0x1f,%eax
80107da1:	c1 fa 05             	sar    $0x5,%edx
80107da4:	29 c2                	sub    %eax,%edx
80107da6:	89 d0                	mov    %edx,%eax
80107da8:	c1 e0 06             	shl    $0x6,%eax
80107dab:	01 d0                	add    %edx,%eax
80107dad:	29 c1                	sub    %eax,%ecx
80107daf:	8b 44 8b 0c          	mov    0xc(%ebx,%ecx,4),%eax
}
80107db3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107db6:	c9                   	leave  
80107db7:	c3                   	ret    
80107db8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107dbf:	90                   	nop

80107dc0 <push>:

void
push(struct Queue *queue, struct proc *p)
{
80107dc0:	55                   	push   %ebp
    if ((queue->rear + 1) % (NPROC + 1) == queue->front)
80107dc1:	ba 7f e0 07 7e       	mov    $0x7e07e07f,%edx
{
80107dc6:	89 e5                	mov    %esp,%ebp
80107dc8:	56                   	push   %esi
80107dc9:	53                   	push   %ebx
80107dca:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if ((queue->rear + 1) % (NPROC + 1) == queue->front)
80107dcd:	8b 43 04             	mov    0x4(%ebx),%eax
80107dd0:	8b 33                	mov    (%ebx),%esi
80107dd2:	8d 48 01             	lea    0x1(%eax),%ecx
80107dd5:	89 c8                	mov    %ecx,%eax
80107dd7:	f7 ea                	imul   %edx
80107dd9:	89 c8                	mov    %ecx,%eax
80107ddb:	c1 f8 1f             	sar    $0x1f,%eax
80107dde:	c1 fa 05             	sar    $0x5,%edx
80107de1:	29 c2                	sub    %eax,%edx
80107de3:	89 d0                	mov    %edx,%eax
80107de5:	c1 e0 06             	shl    $0x6,%eax
80107de8:	01 d0                	add    %edx,%eax
80107dea:	29 c1                	sub    %eax,%ecx
80107dec:	39 f1                	cmp    %esi,%ecx
80107dee:	74 1a                	je     80107e0a <push+0x4a>
    if(isFull(queue))
        return;
    queue->q[queue->front] = p;
80107df0:	8b 45 0c             	mov    0xc(%ebp),%eax
    if(queue->front > 0)
        queue->front--;
80107df3:	85 f6                	test   %esi,%esi
80107df5:	ba 40 00 00 00       	mov    $0x40,%edx
    queue->q[queue->front] = p;
80107dfa:	89 44 b3 0c          	mov    %eax,0xc(%ebx,%esi,4)
        queue->front--;
80107dfe:	8d 46 ff             	lea    -0x1(%esi),%eax
80107e01:	0f 4e c2             	cmovle %edx,%eax
    else
        queue->front = NPROC;
    queue->count++;
80107e04:	83 43 08 01          	addl   $0x1,0x8(%ebx)
80107e08:	89 03                	mov    %eax,(%ebx)
}
80107e0a:	5b                   	pop    %ebx
80107e0b:	5e                   	pop    %esi
80107e0c:	5d                   	pop    %ebp
80107e0d:	c3                   	ret    
80107e0e:	66 90                	xchg   %ax,%ax

80107e10 <printQueue>:

void
printQueue(struct Queue *queue)
{
80107e10:	55                   	push   %ebp
80107e11:	89 e5                	mov    %esp,%ebp
80107e13:	57                   	push   %edi
80107e14:	56                   	push   %esi
80107e15:	53                   	push   %ebx
80107e16:	83 ec 0c             	sub    $0xc,%esp
80107e19:	8b 75 08             	mov    0x8(%ebp),%esi
    if (queue->front == queue->rear)
80107e1c:	8b 46 04             	mov    0x4(%esi),%eax
80107e1f:	39 06                	cmp    %eax,(%esi)
80107e21:	74 7b                	je     80107e9e <printQueue+0x8e>
    int size = queue->count;

    if(!isEmpty(queue)){
        cprintf("queue: ");
80107e23:	83 ec 0c             	sub    $0xc,%esp
    int size = queue->count;
80107e26:	8b 5e 08             	mov    0x8(%esi),%ebx
        cprintf("queue: ");
80107e29:	68 c3 89 10 80       	push   $0x801089c3
80107e2e:	e8 6d 88 ff ff       	call   801006a0 <cprintf>
        int i = (queue->front + 1) % (NPROC + 1);
80107e33:	8b 06                	mov    (%esi),%eax
80107e35:	ba 7f e0 07 7e       	mov    $0x7e07e07f,%edx
        while(size--){
80107e3a:	83 c4 10             	add    $0x10,%esp
        int i = (queue->front + 1) % (NPROC + 1);
80107e3d:	8d 48 01             	lea    0x1(%eax),%ecx
80107e40:	89 c8                	mov    %ecx,%eax
80107e42:	f7 ea                	imul   %edx
80107e44:	89 c8                	mov    %ecx,%eax
80107e46:	c1 f8 1f             	sar    $0x1f,%eax
80107e49:	c1 fa 05             	sar    $0x5,%edx
80107e4c:	89 d7                	mov    %edx,%edi
80107e4e:	29 c7                	sub    %eax,%edi
80107e50:	89 f8                	mov    %edi,%eax
80107e52:	c1 e0 06             	shl    $0x6,%eax
80107e55:	01 f8                	add    %edi,%eax
80107e57:	89 cf                	mov    %ecx,%edi
80107e59:	29 c7                	sub    %eax,%edi
        while(size--){
80107e5b:	85 db                	test   %ebx,%ebx
80107e5d:	74 3f                	je     80107e9e <printQueue+0x8e>
80107e5f:	90                   	nop
            cprintf("%d(%d) ", queue->q[i]->pid, queue->q[i]->state);
80107e60:	8b 44 be 0c          	mov    0xc(%esi,%edi,4),%eax
80107e64:	83 ec 04             	sub    $0x4,%esp
80107e67:	ff 70 0c             	push   0xc(%eax)
80107e6a:	ff 70 10             	push   0x10(%eax)
80107e6d:	68 cb 89 10 80       	push   $0x801089cb
80107e72:	e8 29 88 ff ff       	call   801006a0 <cprintf>
            i = (i + 1) % (NPROC + 1);
80107e77:	8d 4f 01             	lea    0x1(%edi),%ecx
80107e7a:	b8 7f e0 07 7e       	mov    $0x7e07e07f,%eax
        while(size--){
80107e7f:	83 c4 10             	add    $0x10,%esp
            i = (i + 1) % (NPROC + 1);
80107e82:	f7 e9                	imul   %ecx
80107e84:	89 c8                	mov    %ecx,%eax
80107e86:	c1 f8 1f             	sar    $0x1f,%eax
80107e89:	c1 fa 05             	sar    $0x5,%edx
80107e8c:	29 c2                	sub    %eax,%edx
80107e8e:	89 d0                	mov    %edx,%eax
80107e90:	c1 e0 06             	shl    $0x6,%eax
80107e93:	01 d0                	add    %edx,%eax
80107e95:	29 c1                	sub    %eax,%ecx
80107e97:	89 cf                	mov    %ecx,%edi
        while(size--){
80107e99:	83 eb 01             	sub    $0x1,%ebx
80107e9c:	75 c2                	jne    80107e60 <printQueue+0x50>
        }
    }
    cprintf("\n");
80107e9e:	c7 45 08 70 87 10 80 	movl   $0x80108770,0x8(%ebp)
80107ea5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107ea8:	5b                   	pop    %ebx
80107ea9:	5e                   	pop    %esi
80107eaa:	5f                   	pop    %edi
80107eab:	5d                   	pop    %ebp
    cprintf("\n");
80107eac:	e9 ef 87 ff ff       	jmp    801006a0 <cprintf>
