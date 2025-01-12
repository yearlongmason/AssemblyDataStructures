; 2021Day06.asm
; Mason Lee

malloc PROTO
free PROTO
_printInt PROTO
_printLongLong PROTO
_printNewLine PROTO ; Mostly for testing purposes
_printString PROTO
_getFish PROTO

.DATA
QueueNode STRUCT
	data QWORD ?
	nextNode QWORD 0
QueueNode ENDS

LLNode STRUCT
	data QWORD ?
	nextNode QWORD 0
LLNode ENDS

allFish LLNode <0, 0> ; Keeps track of all fish
fishQueue QueueNode <0, 0>
currentNode LLNode <0, 0>
loopCounter QWORD ?
loopPlaceholder QWORD ?
addressPlaceholder QWORD ?
tempDayPassData QWORD ?
dataStructureSum QWORD ?
lastNode QWORD ? ; This will be used as a pointer to the previous node
tempData QWORD ?
headNodePtr QWORD ?
numFishMessage BYTE "Number of lanternfish after ",0
daysMessage BYTE "days: ",0

.CODE


; Parameters: memory address of head node
; Returns: None
_printList PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; Set current node values equal to values in the struct that was passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	cmp currentNode.nextNode, 0
	je finishPrintList

	; This section sets the current node data equal to the next node data
	nextNodeJmp:
	mov rsi, currentNode.nextNode
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; Print data at this index
	mov rcx, currentNode.data
	call _printInt

	; If the value of next node is 0 then there is no next node, so do not loop
	cmp currentNode.nextNode, 0
	jne nextNodeJmp

	finishPrintList:

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_printList ENDP


; Parameters: memory address of head node
; data to be stored at new node
; Returns: None
_addNode PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; move rdx into tempData
	mov tempData, rdx

	; Set current node values equal to values in the struct that was passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; Skips over going to the next node
	jmp skipNextNode

	; This section sets the current node data equal to the next node data
	nextNodeJmp:
	mov rsi, currentNode.nextNode
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	skipNextNode:

	; If the value of next node is 0 then there is no next node, so do not loop
	cmp currentNode.nextNode, 0
	jne nextNodeJmp

	; Add node to the end of the linked list
	mov rcx, 16
	call malloc
	mov [rsi + 8], rax

	; Move to the next node
	mov rsi, [rsi + 8]
	mov rax, tempData ; Get data to add to new node
	mov [rsi], rax
	mov rax, 0
	mov [rsi + 8], rax

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_addNode ENDP


; Parameters: memory address of head node
; index of value to return
; Returns: Value stored at index passed in
_getIndex PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	mov rax, rdx ; Start rax counter
	inc rax ; Incriment rax by 1 to account for the head node

	; Set current node values equal to values in head node passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	mov rcx, rax ; Move the counter to rcx
	; This section sets the current node data equal to the next node data
	nextNodeJmp:
		mov rsi, currentNode.nextNode
		mov rax, [rsi]
		mov currentNode.data, rax
		mov rax, [rsi + 8]
		mov currentNode.nextNode, rax

		loop nextNodeJmp

	mov rax, currentNode.data

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_getIndex ENDP


; Parameters: memory address of head node
; index of value to set
; data to set the value of the index to
; Returns: Value stored at index passed in
_setIndex PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	mov tempData, r8 ; Store data to be set in tempData for now

	mov rax, rdx ; Start rax counter
	inc rax ; Incriment rax by 1 to account for the head node

	; Set current node values equal to values in head node passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	mov rcx, rax ; Move the counter to rcx
	; This section sets the current node data equal to the next node data
	nextNodeJmp:
		mov rsi, currentNode.nextNode
		mov rax, [rsi]
		mov currentNode.data, rax
		mov rax, [rsi + 8]
		mov currentNode.nextNode, rax

		loop nextNodeJmp

	; Set data at correct index to data passed in
	mov rax, tempData
	mov [rsi], rax

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_setIndex ENDP


; Parameters: memory address of head node
; Returns: None
_deleteList PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; Clear lastNode
	xor rax, rax
	mov lastNode, rax

	; Set current node values equal to values in the struct that was passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; Clear head node
	xor rax, rax
	mov [rsi], rax
	mov [rsi + 8], rax

	; This section sets the current node data equal to the next node data
	nextNodeJmp:
	mov rsi, currentNode.nextNode
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; Free the last node
	mov rcx, lastNode
	call free

	mov lastNode, rsi

	; If the value of next node is 0 then there is no next node, so do not loop
	cmp currentNode.nextNode, 0
	jne nextNodeJmp

	; Finally, free the last node
	mov rcx, lastNode
	call free

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_deleteList ENDP


; Parameters: memory address of head node
; data to be stored at new node
; Returns: None
_pushQueue PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; move rdx into tempData
	mov tempData, rdx

	; Set current node values equal to values in the struct that was passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; Skips over going to the next node
	jmp skipNextNode

	; This section sets the current node data equal to the next node data
	nextNodeJmp:
	mov rsi, currentNode.nextNode
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	skipNextNode:

	; If the value of next node is 0 then there is no next node, so do not loop
	cmp currentNode.nextNode, 0
	jne nextNodeJmp

	; Add node to the end of the emd of the queue
	mov rcx, 16
	call malloc
	mov [rsi + 8], rax

	; Move to the next node
	mov rsi, [rsi + 8]
	mov rax, tempData ; Get data to add to new node
	mov [rsi], rax
	mov rax, 0
	mov [rsi + 8], rax

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_pushQueue ENDP


; Parameters: memory address of head node
; Returns: Data at node that was just popped
_popQueue PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; Save off the head node pointer
	mov headNodePtr, rcx

	; Move to next node
	mov rsi, rcx
	mov rsi, [rsi + 8]

	; Save off data and next node ptr in currentNode
	mov rax, [rsi]
	mov currentNode.data, rax
	mov rax, [rsi + 8]
	mov currentNode.nextNode, rax

	; Delete current node (node being popped)
	mov rcx, rsi
	call free

	; Set first node to the next node (currently being stored in currentNode.nextNode)
	mov rsi, headNodePtr
	mov rax, currentNode.nextNode
	mov [rsi + 8], rax

	; Return data stored at node just popped
	mov rax, currentNode.data

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_popQueue ENDP


; Parameters: memory address of head node
; Returns: None
_printQueue PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; Set current node values equal to values in the struct that was passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; If the queue is empty just finish
	cmp currentNode.nextNode, 0
	je finishPrintList

	; This section sets the current node data equal to the next node data
	nextNodeJmp:
	mov rsi, currentNode.nextNode
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; Print data at current index
	mov rcx, currentNode.data
	call _printLongLong

	; If the value of next node is 0 then there is no next node, so do not loop
	cmp currentNode.nextNode, 0
	jne nextNodeJmp

	finishPrintList:

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_printQueue ENDP


; Parameters: memory address of head node
; Returns: None
_deleteQueue PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; Clear last node
	xor rax, rax
	mov lastNode, rax

	; Set current node values equal to values in the struct that was passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; Clear head node
	xor rax, rax
	mov [rsi], rax
	mov [rsi + 8], rax

	; This section sets the current node data equal to the next node data
	nextNodeJmp:
	mov rsi, currentNode.nextNode
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; Free the previous node
	mov rcx, lastNode
	call free

	mov lastNode, rsi ; Save memory address of previous node

	; If the value of next node is 0 then there is no next node, so do not loop
	cmp currentNode.nextNode, 0
	jne nextNodeJmp

	; Finally, free the last node
	mov rcx, lastNode
	call free

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_deleteQueue ENDP


; Parameters: memory address of head node
; index to add value to
; value to add to the index
; Returns: None
_addToIndex PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	mov tempData, r8 ; Store data to be added in tempData for now

	mov rax, rdx ; Start rax counter
	inc rax ; Incriment rax by 1 to account for the head node

	; Set current node values equal to values in head node passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	mov rcx, rax ; Move the counter to rcx
	; This section sets the current node data equal to the next node data
	nextNodeJmp:
		mov rsi, currentNode.nextNode
		mov rax, [rsi]
		mov currentNode.data, rax
		mov rax, [rsi + 8]
		mov currentNode.nextNode, rax

		loop nextNodeJmp

	; Set data at correct index to data passed in
	mov rax, tempData
	add [rsi], rax

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_addToIndex ENDP


; Parameters: memory address of head node
; Returns: None
_dayPass PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; Pop 0th value and give the data from the popped value to rdx
	mov addressPlaceholder, rcx
	call _popQueue
	mov tempDayPassData, rax

	; Push value just popped off onto the queue
	mov rcx, addressPlaceholder
	mov rdx, tempDayPassData
	call _pushQueue

	; Add value just popped off to index 6 to restart fish internal counter
	mov rcx, addressPlaceholder
	mov rdx, 6
	mov r8, tempDayPassData
	call _addToIndex

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called
_dayPass ENDP


; Parameters: memory address of head node
; Returns: Sum of all values in the data structure
_getSum PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; Set current node values equal to values in the struct that was passed in
	mov rsi, rcx
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; Clear data structure sum
	mov rax, 0
	mov dataStructureSum, rax

	; If the queue is empty just finish
	cmp currentNode.nextNode, 0
	je finishSum

	; This section sets the current node data equal to the next node data
	nextNodeJmp:
	mov rsi, currentNode.nextNode
	mov rcx, [rsi]
	mov currentNode.data, rcx
	mov rcx, [rsi + 8]
	mov currentNode.nextNode, rcx

	; add current data to sum
	mov rcx, currentNode.data
	add dataStructureSum, rcx

	; If the value of next node is 0 then there is no next node, so do not loop
	cmp currentNode.nextNode, 0
	jne nextNodeJmp

	finishSum:

	; Return the sum of the data structure
	mov rax, dataStructureSum

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_getSum ENDP


_partOne PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; Get data from text file using C++ function
	lea rcx, allFish
	call _getFish

	; Create fish queue
	mov rcx, 9
	addToQueue:
	mov loopCounter, rcx ; Save off loop counter

	; Add new node (starting at 0) to fishQueue
	lea rcx, fishQueue
	mov rdx, 0
	call _pushQueue

	mov rcx, loopCounter ; Restore loop counter
	loop addToQueue

	; Loop through all fish to get counts for fish queue
	lea rsi, allFish
	toNextNode:
	mov rsi, [rsi + 8] ; Start at first node with data
	mov addressPlaceholder, rsi ; Save rsi

	lea rcx, fishQueue
	mov rdx, [rsi]
	mov r8, 1
	call _addToIndex

	mov rsi, addressPlaceholder ; Restore rsi
	mov rax, [rsi + 8] ; Get the pointer to the next node
	cmp rax, 0 ; if the next node is 0, then we made it to the end
	jne toNextNode

	; Print populated fish queue as a test
	;lea rcx, fishQueue
	;call _printQueue
	;call _printNewLine

	mov rcx, 80 ; Start loop counter with the number of days based on the question
	dayPassLoop:
	mov loopPlaceholder, rcx ; Save off rcx

	lea rcx, fishQueue
	call _dayPass

	; Print queue at current day for testing purposes
	;lea rcx, fishQueue
	;call _printQueue
	;call _printNewLine

	mov rcx, loopPlaceholder ; Load back rcx
	loop dayPassLoop

	; Get the sum of the queue (all the fish)
	lea rcx, fishQueue
	call _getSum
	mov tempData, rax

	; Print out answer
	lea rcx, numFishMessage
	call _printString
	mov rcx, 80
	call _printInt
	lea rcx, daysMessage
	call _printString
	mov rcx, tempData
	call _printLongLong
	call _printNewLine

	; Delete list of fish to avoid memory leaks
	lea rcx, allFish
	call _deleteList

	; Delete fishQueue to avoid memory leaks
	lea rcx, fishQueue
	call _deleteQueue

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_partOne ENDP


_partTwo PROC
	push rbp ; Push frame pointer onto the stack
	sub rsp, 20h
	lea rbp, [rsp + 20h]

	; Get data from text file using C++ function
	lea rcx, allFish
	call _getFish

	; Create fish queue
	mov rcx, 9
	addToQueue:
	mov loopCounter, rcx ; Save off loop counter

	; Add new node (starting at 0) to fishQueue
	lea rcx, fishQueue
	mov rdx, 0
	call _pushQueue

	mov rcx, loopCounter ; Restore loop counter
	loop addToQueue

	; Loop through all fish to get counts for fish queue
	lea rsi, allFish
	toNextNode:
	mov rsi, [rsi + 8] ; Start at first node with data
	mov addressPlaceholder, rsi ; Save rsi

	; Add one to the correct fish index
	lea rcx, fishQueue
	mov rdx, [rsi]
	mov r8, 1
	call _addToIndex

	mov rsi, addressPlaceholder ; Restore rsi
	mov rax, [rsi + 8] ; Get the pointer to the next node
	cmp rax, 0 ; if the next node is 0, then we made it to the end
	jne toNextNode

	; Print populated fish queue as a test
	;lea rcx, fishQueue
	;call _printQueue
	;call _printNewLine

	mov rcx, 256 ; Start loop counter with the number of days based on the question
	dayPassLoop:
	mov loopPlaceholder, rcx ; Save off rcx

	lea rcx, fishQueue
	call _dayPass

	; Print queue at current day for testing purposes
	;lea rcx, fishQueue
	;call _printQueue
	;call _printNewLine

	mov rcx, loopPlaceholder ; Load back rcx
	loop dayPassLoop

	; Get the sum of the queue (all the fish)
	lea rcx, fishQueue
	call _getSum
	mov tempData, rax

	; Print out answer
	lea rcx, numFishMessage
	call _printString
	mov rcx, 256
	call _printInt
	lea rcx, daysMessage
	call _printString
	mov rcx, tempData
	call _printLongLong
	call _printNewLine

	; Delete list of fish to avoid memory leaks
	lea rcx, allFish
	call _deleteList

	; Delete fishQueue to avoid memory leaks
	lea rcx, fishQueue
	call _deleteQueue

	lea rsp, [rbp]
	pop rbp ; Pop frame pointer from the stack
	ret ; return to where function was called

_partTwo ENDP
END