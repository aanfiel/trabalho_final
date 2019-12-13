// TRABALHO FINAL DE INTELIGÊNCIA COMPUTACIONAL
// Aluno: José Lopes de Souza Filho
// Matrícula: 389097
// Aplicação: Scilab, versão 6.0.2
// SO: Linux Mint 19.2 Tina
//-----------------------------------------------------------------------------
//ALGORITMO GENÉTICO: CAIXEIRO VIAJANTE

clear;  // Limpa as variáveis armazenadas
clc;    // Limpa a tela

// Cria a matriz de adjacência dada na questão
MA = [0	1 2	4 6	2 2	3 3	5 6	1 4	5;
      1	0 3	2 1	3 6	3 4	4 2	4 4	4;
      2	3 0	1 3	3 2	3 4	1 3	5 5	6;
      4	2 1	0 5	1 4	2 3	4 4	8 2	2;
      6	1 3	5 0	2 1	6 5	2 3	4 2	2;
      2	3 3	1 2	0 3	1 2	3 5	7 3	4;
      2	6 2	4 1	3 0	2 1	2 5	2 4	3;
      3	3 3	2 6	1 2	0 5	5 1	5 3	6;
      3	4 4	3 5	2 1	5 0	1 4	4 5	3;
      5	4 1	4 2	3 2	5 1	0 5	4 4	2;
      6	2 3	4 3	5 5	1 4	5 0	4 2	1;
      1	4 5	8 4	7 2	5 4	4 4	0 1	3;
      4	4 5	2 2	3 4	3 5	4 2	1 0	1;
      5	4 6	2 2	4 3	6 3	2 1	3 1	0];

// PARTE 1: CRIA A GERAÇÃO INICIAL DE CROMOSSOMOS

geracoes = 100;     // Número de gerações usadas
n_pop = 100;        // Tamanho da população de cromossomos
tam_cromo = 14      // Tamanho do cromossomo a ser criado
prob = 0.1          // Probabilidade de mutação (0 a 100%)

for i = 1:n_pop
    POP(i,:) = grand(1, "prm", (1:tam_cromo)')';    // Cria um vetor de tamanho tam_cromo com números aleatórios entre 1 e tam_cromo SEM REPETIÇÕES
end
POP_INICIAL = POP;  //Guarda a população inicial apenas para fins comparativos no final

//---------------------------------------------------------------------------------------
// ATENÇÃO: DAQUI EM DIANTE COMEÇA O LOOP PARA NOVAS GERAÇÕES
//---------------------------------------------------------------------------------------

for f2 = 1:geracoes,    // Cria um laço maior que cria novas gerações 

// PARTE 2: AVALIAÇÃO DOS CROMOSSOMOS

AV = zeros(n_pop, 1);   // Cria um vetor de avaliações zerado

for i = 1:n_pop
    for j = 1:tam_cromo-1
        AV(i) = AV(i) + MA(POP(i,j),POP(i,j+1));    // Preenche o vetor de avaliações com as notas respectivas para cada cromossomo
    end
end

// PARTE 3: SELEÇÃO DOS PAIS (ROLETA VICIADA)

function [pai]=giraroleta()
    av_inv = (max(AV)+1)-AV; // Como buscamos valores mínimos foi necessário realizar uma inversão, para que desse modo os menores valores tivessem maior fatia na roleta e vice versa. Para isso subtraí o valor da avaliação do valor máximo encontrado + 1 unidade (para que ninguém fique com avaliação igual a 0). Assim as avaliações se inverteram. Os menores valores passam a ter uma avaliação maior para a roleta.
    soma_inv = sum(av_inv); // Soma dos valores invertidos
    s = grand(1, 1, "unf", 1, soma_inv);    // Selecione um número s entre 0 e soma (Não incluídos)
    pai = 1;
    aux = av_inv(1);
    while aux < s,
        pai = pai + 1;
        aux = aux + av_inv(i);
    end
    
endfunction

// ATENÇÃO: TRECHO DE CÓDIGO DE PROTEÇÃO
// Não sei por qual motivo, o pseudocódigo da roleta do slide às vezes sorteia um número acima do tamanho da população gerando um erro. Para garantir que o número sorteado nunca fique acima de 100, criei uma proteção que toda vez que o número sorteado ficar acima de 100 a roleta gire novamente respeitando as probabilidades, até que um número abaixo de 100 seja encontrado e usado.
function [indice]=geraindice()
indice = giraroleta();
if indice > n_pop
    while indice > n_pop,
    indice = giraroleta();
    end
end
endfunction
//----------------------------------------------------------------------------------------

//PARTE 4 - GERAÇÃO DO(S) FILHO(S) (CROSSOVER)
// Crossover baseado em ordem

for f = 1:n_pop,  //Nova geração com 100 indivíduos

// Seleciona dois pais da geração anterior
pais(1,:) = POP(geraindice(),:);    // Escolhe o pai 1
pais(2,:) = POP(geraindice(),:);    // Escolhe o pai 2

filho = zeros(1,14);
SS = grand(1, 14, "uin", 0, 1); // Gera a string de seleção

for i = 1:14,
    if SS(1,i) == 1
        filho(1,i) = pais(1,i);
    end
end

for k = 1:14,
    if SS(1,k) == 0
        for l = 1:14
            busca_filho = find(filho==pais(2,l));
            if busca_filho == [],
            filho(1,k) = pais(2,l);
            break;
            end
        end
    end
end

// Mutação baseada em ordem

aleatorio = rand(); // Sorteia um número aleatório qualquer entre 0 e 1

if aleatorio < prob then
    gene1 = grand(1,1,"uin",1,14);  // Seleciona um gene aleatório para troca
    gene2 = grand(1,1,"uin",1,14);  // Seleciona outro gene aleatório para troca
    filho_aux = filho;
    filho(1,gene1) = filho_aux(1,gene2);
    filho(1,gene2) = filho_aux(1,gene1);
end

// Cria uma nova geração de filhos
POP(f,:) = filho;

end
end

// PARTE FINAL: EXIBE OS RESULTADOS NO CONSOLE

[ma, mc] = min(AV); //ma = melhor valor de avaliação - mc = índice do melhor cromossomo

melhor_percurso = POP(mc,:);
melhor_avaliacao = AV(mc);

disp("----------------- ALGORITMO GENÉTICO BASEADO EM ORDEM ----------------- ")
disp("Número de gerações: "+ string(geracoes));
disp("Número de indivíduos por geração: "+ string(n_pop));
disp("Probabilidade de mutação: "+ string(prob*100) + "%");
disp("Melhor percurso encontrado:");
disp(melhor_percurso);
disp("Distância deste percurso: " + string(melhor_avaliacao) + " unidades de distância.");
disp("------------------------------------------------------------------------")
