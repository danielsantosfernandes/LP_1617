%Daniel Fernandes 86400

:-include('SUDOKU').


%---------------tira_num_aux(Num,Puz,Pos,N_Puz)----------------------------

tira_num_aux(Num, Puz, Pos, N_Puz):-puzzle_ref(Puz, Pos, Cont),
									member(Num, Cont),!,
									subtract(Cont, [Num], Res),
									puzzle_muda_propaga(Puz, Pos, Res, N_Puz).

tira_num_aux(_, Puz, _, Puz):-!.

%---------------tira_num(Num,Puz,Posicoes,N_Puz)---------------------------

tira_num(Num, Puz, Posicoes, N_Puz):-percorre_muda_Puz(Puz, tira_num_aux(Num), Posicoes, N_Puz).

%---------------puzzle_muda_propaga(Puz, Pos, Cont, N_Puz)-----------------

puzzle_muda_propaga(Puz, Pos, [Num|Resto], N_Puz):-Resto==[],!,
												   puzzle_muda(Puz, Pos, [Num], Novo),
												   posicoes_relacionadas(Pos, Rel),
												   tira_num(Num, Novo, Rel, N_Puz).
			

puzzle_muda_propaga(Puz, Pos, Cont, N_Puz):-!,puzzle_muda(Puz, Pos, Cont, N_Puz).


%---------------possibilidades(Pos,Puz,Poss)-------------------------------

possibilidades(Pos, Puz, Poss):-posicoes_relacionadas(Pos, Rel),
								conteudos_posicoes(Puz, Rel, Cont),
								filtra_conteudo(Cont, [], N_Cont),
								sort(N_Cont, NaoPoss),
								numeros(Numeros),
								subtract(Numeros, NaoPoss, Poss).

%auxiliar de possibilidades/3.
%filtra_conteudo(Cont, Ac, N_Cont) significa que N_Cont e uma lista
%com apenas os numeros que estejam numa lista unitaria de Cont,
%Ac e um acumulador auxiliar.

filtra_conteudo([], N_Cont, N_Cont).

filtra_conteudo([[P|R]|Resto], Ac, N_Cont):-R==[],!,
											filtra_conteudo(Resto, [P|Ac], N_Cont).

filtra_conteudo([_|Resto], Ac, N_Cont):-filtra_conteudo(Resto, Ac, N_Cont).

%---------------inicializa_aux(Puz,Pos,N_Puz)------------------------------

inicializa_aux(Puz, Pos, N_Puz):-puzzle_ref(Puz, Pos, [_|R]),
								 R==[],!,
								 N_Puz=Puz.
								

inicializa_aux(Puz, Pos, N_Puz):-possibilidades(Pos, Puz, Poss),
								 puzzle_muda_propaga(Puz, Pos, Poss, N_Puz).

%---------------inicializa(Puz,N_Puz)--------------------------------------

inicializa(Puz, N_Puz):-todas_posicoes(Posicoes),
						percorre_muda_Puz(Puz, inicializa_aux,Posicoes, N_Puz).

%---------------so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num)---------------

so_aparece_uma_vez(Puz, Num, [P|R], Pos_Num):-puzzle_ref(Puz, P, Cont),
											  member(Num, Cont),!,
											  nao_aparece(Puz, Num, R),
											  Pos_Num=P.

so_aparece_uma_vez(Puz, Num, [_|R], Pos_Num):-so_aparece_uma_vez(Puz, Num, R, Pos_Num).

%auxiliar de so_aparece_uma_vez/4.
%nao_aparece(Puz, Num, Posicoes) significa que o numero Num nao aparece na lista
%de posicoes Posicoes do puzzle Puz.

nao_aparece(_, _, []).

nao_aparece(Puz, Num, [P|R]):-puzzle_ref(Puz, P, Cont),
							  \+member(Num, Cont),
							  nao_aparece(Puz, Num, R).

%---------------inspecciona_num(Posicoes,Puz,Num,N_Puz)--------------------

inspecciona_num(Posicoes, Puz, Num, N_Puz):-so_aparece_uma_vez(Puz, Num, Posicoes, Pos),
											puzzle_ref(Puz, Pos, [_|R]),
											R \=[],!,
											puzzle_muda_propaga(Puz, Pos, [Num], N_Puz).

inspecciona_num(_, Puz, _, Puz).

%---------------inspecciona_grupo(Puz,Gr,N_Puz)----------------------------

inspecciona_grupo(Puz, Gr, N_Puz):-numeros(N),
								   percorre_muda_Puz(Puz, inspecciona_num(Gr), N, N_Puz).

%---------------inspecciona(Puz,N_Puz)-------------------------------------

inspecciona(Puz, N_Puz):-grupos(Gr),
						 percorre_muda_Puz(Puz, inspecciona_grupo, Gr, N_Puz).

%---------------grupo_correcto(Puz,Nums,Gr)--------------------------------

grupo_correcto(Puz, Nums, Gr):-conteudos_posicoes(Puz, Gr, Conteudos),
							   cont_uni(Nums, Conteudos).

%auxiliar de grupo_correcto/3.
%cont_uni(Nums, Conteudos) significa que Conteudos e
%(i) uma lista de listas unitarias e
%(ii)universal, ou seja, contem todos os numeros em Num.

cont_uni([],[]):-!.

cont_uni(_, []):-fail.

cont_uni(Nums, [[P|R]|Resto]):-R==[],!,
							   subtract(Nums, [P], N_Nums),
							   cont_uni(N_Nums, Resto).

%---------------solucao(Puz)-----------------------------------------------

solucao(Puz):-numeros(N),
			  grupos(Gr),
			  solucao_aux(Puz, N, Gr).

%auxiliar de solucao/1.
%solucao_aux(Puz, N, Gr) significa que todos os grupos em Gr sao
%grupo corretos do puzzle Puz, N e a lista de todos os numeros.

solucao_aux(_, _, []):-!.

solucao_aux(Puz, N, [P|R]):-grupo_correcto(Puz, N, P),
							solucao_aux(Puz, N, R).

%---------------resolve(Puz,Sol)-------------------------------------------

resolve(Puz, Sol):-inicializa(Puz, N_Puz),
				   (
					   solucao(N_Puz) -> Sol=N_Puz
					   ;
					   resolve_aux(N_Puz, Sol)
				   ).

%auxiliares de resolve/2.
%resolve_aux(Puz, Sol) e um ciclo que aplica resolve_inspecciona/2 e
%resolve_propaga/2 ate encontrar solucao.

resolve_aux(Puz, Sol):-resolve_inspecciona(Puz, Puz1),
					   (
						   solucao(Puz1) -> Sol=Puz1
						   ;
						   resolve_propaga(Puz1, Puz2),
						   (
							   solucao(Puz2) -> Sol=Puz2
							   ;
							   resolve_aux(Puz2, Sol)
						   )
					   ).


%resolve_inspecciona(Puz, Novo) e um ciclo que aplica inspecciona/2 ao puzzle
%Puz ate que nao haja mudanca.

resolve_inspecciona(Puz, Novo):-inspecciona(Puz, N_Puz),writeln('a'),
								(
									Puz=N_Puz -> Novo=N_Puz
									;
									writeln('b'),resolve_inspecciona(N_Puz, Novo)
								).


%resolve_propaga(Puz, Novo) escolhe uma posicao nao unitaria de Puz
%e uma das possibilidades dessa posicao para tentar resolver aplicando 
%puzzle_muda_propaga/4.

resolve_propaga(Puz, Novo):-todas_posicoes(Posicoes),writeln('c'),
							escolhe_nao_unitaria(Puz, Posicoes, Pos),
							puzzle_ref(Puz, Pos, Cont),
							member(Num, Cont),
							puzzle_muda_propaga(Puz, Pos, [Num], Novo).

%auxiliar de resolve_propaga/2.
%escolhe_nao_unitaria(Puz, Posicoes, Pos) significa que Pos e uma posicao da lista
%Posicoes nao unitaria do puzzle Puz.

escolhe_nao_unitaria(Puz, [P|R], Pos):-puzzle_ref(Puz, P, [_|V]),
									   V=[],!,
									   escolhe_nao_unitaria(Puz, R, Pos).

escolhe_nao_unitaria(_, [P|_], P):-!.

%--------------------------------------------------------------------------

