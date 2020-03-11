extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# CONSTANTES
var ANO_INICIAL = 2017

var POTENCIA_DO_ANO_ZERO_SOLAR = 100000 #???? #GW
var POTENCIA_DO_ANO_ZERO_VENTO= 100000 #????
var POTENCIA_DO_ANO_ZERO_BIOMASSA = 100000 #????

var POTENCIA_MAXIMA_SOLAR = 1000000 #????
var POTENCIA_MAXIMA_VENTO = 1000000 #????
var POTENCIA_MAXIMA_BIOMASSA= 1000000 #????

var CUSTO_POR_GIGAWATT_INSTALADO = 5000 #???? #euro/GW

var PERCENTAGEM_A_RETIRAR_DO_PIB = 0.02 #???? #valor decimal

var POPULACAO = 10000000 #????
var ALFA = 0.60 #???? #percentagem de população



# VARIÁVEIS
var ano_atual_indice = 0
var ano_atual = ano_atual_indice + ANO_INICIAL

## VARS DECISOES 
var input_potencia_a_instalar = 0.0 #(Atenção à divisão de inteiros em GDScript)
var input_percentagem_tipo_economia_transportes = 0.0
var input_percentagem_tipo_economia_industria = 0.0
var input_percentagem_tipo_economia_residencial = 0.0
var input_percentagem_tipo_economia_servicos = 0.0
var input_percentagem_eletrificacao_transportes = 0.0
var input_percentagem_eletrificacao_industria = 0.0
var input_percentagem_eletrificacao_residencial = 0.0
var input_percentagem_eletrificacao_servicos = 0.0

## VARS 1)
var potencia_solar_instantanea = 0.0
var potencia_vento_instantanea = 0.0
var potencia_biomassa_instantanea = 0.0

var potencia_do_ano_solar = [POTENCIA_DO_ANO_ZERO_SOLAR]
var potencia_do_ano_vento = [POTENCIA_DO_ANO_ZERO_VENTO]
var potencia_do_ano_biomassa = [POTENCIA_DO_ANO_ZERO_BIOMASSA]

## VARS 2)
var custo_total_do_ano = [0.0] #valor 2017????
var custo_do_ano_solar = [0.0]
var custo_do_ano_vento = [0.0]
var custo_do_ano_biomassa = [0.0]

## VARS 3)
var pib_do_ano = [900000000.0] #valor 2017????
var investimento_total_do_ano = [0.0]
var investimento_para_capital_do_ano = [0.0]

## VARS 4)
var capital_do_ano = [5000000.0] #valor 2017 necessario! ????

## VARS 5)
var labour_do_ano = [0] 

## VARS 6)
var tfp_do_ano = [0]
var eficiencia_agregada_do_ano = [0.7] #valor 2017 necessario! ???? percentagem decimal

## VARS 8)
var exergia_util_do_ano = [0.0] #TJ

## VARS 9)
var exergia_final_do_ano = [0.0] #TJ


# FUNÇÕES
func indice_do_ano(ano):
	return ano - ANO_INICIAL
	
# FUNCS 0) - PREPARAÇÃO
func mudar_de_ano():
	ano_atual += 1
	ano_atual_indice += 1
	

# FUNCS 1) - POTENCIA ELETRICA ACUMULADA POR FONTE RENOVÁVEL
# TODO: Evitar
func calcular_distribuicao_por_fonte():
	
	var potencia_maxima_solar_alcancada = (potencia_do_ano_solar.back() >= POTENCIA_MAXIMA_SOLAR)
	var potencia_maxima_vento_alcancada = (potencia_do_ano_vento.back() >= POTENCIA_MAXIMA_VENTO)
	var potencia_maxima_biomassa_alcancada = (potencia_do_ano_biomassa.back() >= POTENCIA_MAXIMA_BIOMASSA)
	
	#111
	potencia_solar_instantanea = 0.0
	potencia_vento_instantanea = 0.0
	potencia_biomassa_instantanea = 0.0
	
	if(!potencia_maxima_solar_alcancada && !potencia_maxima_vento_alcancada && !potencia_maxima_biomassa_alcancada): #000
		potencia_solar_instantanea = input_potencia_a_instalar / 3
		potencia_vento_instantanea = input_potencia_a_instalar / 3
		potencia_biomassa_instantanea = input_potencia_a_instalar / 3
	elif(!potencia_maxima_solar_alcancada && !potencia_maxima_vento_alcancada && potencia_maxima_biomassa_alcancada): #001
		potencia_solar_instantanea = input_potencia_a_instalar / 2
		potencia_vento_instantanea = input_potencia_a_instalar / 2
	elif(!potencia_maxima_solar_alcancada && potencia_maxima_vento_alcancada && potencia_maxima_biomassa_alcancada): #011
		potencia_solar_instantanea = input_potencia_a_instalar
	elif(potencia_maxima_solar_alcancada && !potencia_maxima_vento_alcancada && !potencia_maxima_biomassa_alcancada): #100
		potencia_vento_instantanea = input_potencia_a_instalar / 2
		potencia_biomassa_instantanea = input_potencia_a_instalar / 2
	elif(potencia_maxima_solar_alcancada && !potencia_maxima_vento_alcancada && potencia_maxima_biomassa_alcancada): #101
		potencia_vento_instantanea = input_potencia_a_instalar
	elif(!potencia_maxima_solar_alcancada && potencia_maxima_vento_alcancada && !potencia_maxima_biomassa_alcancada): #010
		potencia_solar_instantanea = input_potencia_a_instalar / 2
		potencia_biomassa_instantanea = input_potencia_a_instalar / 2
	elif(potencia_maxima_solar_alcancada && potencia_maxima_vento_alcancada && !potencia_maxima_biomassa_alcancada): #110
		potencia_biomassa_instantanea = input_potencia_a_instalar
	
# Prevenção da quebra dos limites máximos
	if((potencia_do_ano_solar.back() + potencia_solar_instantanea) > POTENCIA_MAXIMA_SOLAR):
		potencia_solar_instantanea = POTENCIA_MAXIMA_SOLAR - potencia_do_ano_solar.back()
	if((potencia_do_ano_vento.back() + potencia_vento_instantanea) > POTENCIA_MAXIMA_VENTO):
		potencia_vento_instantanea = POTENCIA_MAXIMA_VENTO - potencia_do_ano_vento.back()
	if((potencia_do_ano_biomassa.back() + potencia_biomassa_instantanea) > POTENCIA_MAXIMA_BIOMASSA):
		potencia_biomassa_instantanea = POTENCIA_MAXIMA_BIOMASSA - potencia_do_ano_biomassa.back()
	
# Soma dos valores instantâneos aos do ano anterior e adição ao vetor respetivo
	potencia_do_ano_solar.push_back(potencia_do_ano_solar.back() + potencia_solar_instantanea)
	potencia_do_ano_vento.push_back(potencia_do_ano_vento.back() + potencia_vento_instantanea)
	potencia_do_ano_biomassa.push_back(potencia_do_ano_biomassa.back() + potencia_biomassa_instantanea)
	
	
# FUNCS 2) - CUSTO DA POTÊNCIA (euros)
func calcular_custo_anual():
	
	var custo_solar_instantaneo = potencia_solar_instantanea * CUSTO_POR_GIGAWATT_INSTALADO
	var custo_vento_instantaneo = potencia_vento_instantanea * CUSTO_POR_GIGAWATT_INSTALADO
	var custo_biomassa_instantaneo = potencia_biomassa_instantanea * CUSTO_POR_GIGAWATT_INSTALADO
	
	custo_do_ano_solar.push_back(custo_solar_instantaneo)
	custo_do_ano_vento.push_back(custo_vento_instantaneo)
	custo_do_ano_biomassa.push_back(custo_biomassa_instantaneo)
	
	custo_total_do_ano.push_back(custo_solar_instantaneo + custo_vento_instantaneo + custo_biomassa_instantaneo)
	

# FUNCS 3) - INVESTIMENTO (euros)
func calcular_investimento_anual():
	
	var investimento_total_instantaneo = PERCENTAGEM_A_RETIRAR_DO_PIB * pib_do_ano.back()
	
	investimento_total_do_ano.push_back(investimento_total_instantaneo)
	investimento_para_capital_do_ano.push_back(investimento_total_instantaneo - custo_total_do_ano[ano_atual_indice])
	
# FUNCS 4) - CAPITAL (euros?)
func calcular_capital_anual():

	capital_do_ano.push_back(capital_do_ano.back() + investimento_para_capital_do_ano[ano_atual_indice])

# FUNCS 5) - LABOUR (nº de pessoas)
func calcular_labour_anual():
	
	labour_do_ano.push_back(ALFA * POPULACAO)
	
# FUNCS 6) - TOTAL FACTOR PRODUTIVITY (TFP)
func calcular_tfp_anual():
	
	tfp_do_ano.push_back(1.87 * eficiencia_agregada_do_ano.back())
	
# FUNCS 7) - PIB (euros?)
func calcular_pib_anual(): #????
	#"função que utiliza os valores de labour(t), capital(t), e tfp(t)
	pib_do_ano.push_back(pib_do_ano.back() + 1000000) #FUNÇAO DUMMY
	
# FUNCS 8) - EXERGIA ÚTIL ANUAL (1 terajoule = 1 euro)
func calcular_exergia_util_anual():
	exergia_util_do_ano.push_back(pib_do_ano[ano_atual_indice])
	
# FUNCS 9) - EXERGIA FINAL ANUAL
func calcular_exergia_final_anual():
	exergia_final_do_ano.push_back(exergia_util_do_ano[ano_atual_indice] / eficiencia_agregada_do_ano.back())

# FUNCS 10) - SHARES DE EXERGIA FINAL POR SETOR

# FUNCS 11) - SHARES DE EXERGIA FINAL POR SETOR POR CARRIER

# FUNCS 12) - EXERGIA FINAL POR SETOR

# FUNCS 13) - EXERGIA FINAL POR SETOR POR CARRIER

# FUNCS 14) - EFICIÊNCIA POR SETOR

# FUNCS 15) - EFICIÊNCIA AGREGADA (para cálculos em anos futuros)

# FUNCS 16) - EXERGIA FINAL POR CARRIER

# FUNCS 17) - EMISSÕES DE CO2 POR CARRIER (exceto eletricidade) (não há passo 18)

# FUNCS 19) - ELETRICIDADE VINDA DE FONTES RENOVÁVEIS (i.e. emissões zero)

# FUNCS 20) - ELETRICIDADE NÃO RENOVÁVEL

# FUNCS 21) e 22) - EMISSÕES NÃO RENOVÁVEIS

# FUNCS 23) - EMISSÕES TOTAIS (um dos objetivos do jogo) (Toneladas)

# FUNCS 24) - CONSUMO

# FUNCS 25) - UTILIDADE (Felicidade dos cidadãos; um dos objetivos do jogo)
	