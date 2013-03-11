all:
	@cd asma	; make
	@cd asmb	; make
	@cd scanner	; make
	@cd parser	; make
	@cd ag		; make

clean:
	@cd asma	; make clean
	@cd asmb	; make clean
	@cd scanner	; make clean
	@cd parser	; make clean
	@cd ag		; make clean
