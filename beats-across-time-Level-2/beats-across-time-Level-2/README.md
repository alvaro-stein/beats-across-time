# Beats Across Time
# Documentação do Projeto

Este documento descreve a arquitetura base e os principais sistemas implementados até então no projeto, com foco em como utilizá-los e integrá-los.

## Autoloads (Singletons)

Autoloads no Godot são scripts/scenes Singletons que são carregados automaticamente no início do jogo e estão sempre acessíveis globalmente. Isso significa que você pode chamar suas funções de qualquer script no projeto sem precisar de uma referência direta (ex: `Conductor.load_song(...)`).

Eles são usados para gerenciar sistemas centrais que precisam persistir entre cenas ou que precisam ser acessados de múltiplos lugares, como gerenciamento de áudio, inputs, transição de cenas e estado global do jogo.

---

### Conductor

O `Conductor` é o "Maestro" do jogo, responsável por todo o gerenciamento de tempo e ritmo da música.

* **Responsabilidade:**
	* Carregar os dados da música (`SongData`).
	* Tocar o `AudioStreamPlayer` principal.
	* Calcular o `song_time` (tempo da música em segundos) com precisão, ajustando pela latência do áudio.
	* Rastrear a batida atual (`last_beat`) e a próxima batida (`next_beat`).
	* Disparar o sinal `beat_hit` a cada batida que ocorre na música.
	* Disparar o sinal `song_started` quando a música começa.

* **Como usar?**

	Para reagir a cada batida da música (ex: para mover um elemento visual):
	```gdscript
	# Conecta o sinal na função _ready
	func _ready() -> void:
		Conductor.beat_hit.connect(_on_beat_hit)

	# Esta função será chamada automaticamente a cada batida
	func _on_beat_hit(beat: Conductor.BeatInfo, measure_pos: int) -> void:
		# BeatInfo é um tipo que contém a propriedades .pos e .time
		# beat.pos é a posição da contagem de batidas (0, 1, 2, 3...)
		# beat.time é o tempo exato que aconteceu a batida
		# measure_pos é a posição dentro do compasso (1, 2, 3, 4)
		print("Batida! Posição: ", beat.pos)
	```

---

### InputJudge

O `InputJudge` ("Juiz de Input") avalia as ações do jogador contra o ritmo da música.

* **Responsabilidade:**
	* Ouvir os eventos de input do jogador (ex: "space", "up", etc.).
	* Quando um input ocorre, ele pega o `song_time` atual do `Conductor`.
	* Compara o tempo do input com a batida mais próxima (seja a `last_beat` ou `next_beat` do `Conductor`).
	* Dispara o sinal `action_judged` com o resultado: `HIT` (acerto) ou `MISS` (erro), e a margem de erro em milissegundos (ms).
	* Possui uma janela de acerto (`HIT_WINDOW`) de 80ms (0.08s).

* **Como usar?**

	Para reagir a um julgamento de input:
	```gdscript
	# Conecta o sinal na função _ready
	func _ready() -> void:
		InputJudge.action_judged.connect(_on_action_judged)

	# Esta função será chamada sempre que um input for julgado
	func _on_action_judged(action: StringName, judgement: InputJudge.Judgment, error_ms: int) -> void:
		# 'action' é a ação que foi pressionada (ex: &"space")
		if action == &"space":
			if judgement == InputJudge.Judgment.HIT:
				print("Acertou! Erro: %dms" % error_ms)
			else:
				print("Errou. :(")
	```

---

### SceneManager

O `SceneManager` é o gerenciador global para transição de cenas.

* **Responsabilidade:**
	* Manter um registro (dicionário `MAIN_SCENES_UIDS`) de todas as cenas principais e seus UIDs (caminhos de arquivo).
	* Fornecer uma função (`change_scene_to`) para trocar a cena atual do jogo por uma nova.
	* Carregar a cena inicial do jogo (atualmente `MainScene.MENU`) de forma segura após o bootloader.

* **Como usar?**

	Para trocar de cena (ex: de um botão no menu):
	```gdscript
	# Exemplo para ir para a cena de teste de ritmo
	func _on_rhythm_test_button_pressed() -> void:
		SceneManager.change_scene_to(SceneManager.MainScene.RHYTHM_TEST)
	```

---

### SongDB

O `SongDB` ("Banco de Dados de Músicas") é um utilitário para facilitar o carregamento de recursos de músicas.

* **Responsabilidade:**
	* Manter um `enum` (`Song`) para nomes de músicas fáceis de usar.
	* Manter um dicionário (`SONGS_UIDS`) que mapeia o `enum` da música ao UID (caminho) do seu arquivo de recurso (`.tres`).
	* Fornecer a função `get_song_data(song: Song)` que carrega e retorna o recurso `SongData` solicitado.

* **Como usar?**

	Para obter os dados de uma música (geralmente para passar ao `Conductor`):
	```gdscript
	# Carrega os dados da música de teste
	var song_data: SongData = SongDB.get_song_data(SongDB.Song.TEST_SONG)
	
	# Agora 'song_data' pode ser usado
	print(song_data.name)
	Conductor.load_song(song_data)
	```

---

### GameManager

Autoload genérico para gerenciar o estado global do jogo.

* **Responsabilidade:**
	* (Atualmente vazio).
	* Destinado a armazenar informações que precisam persistir entre as cenas, como pontuação, vida do jogador, configurações, etc.


## Recursos (Custom Resources)

Recursos customizados são arquivos de dados (geralmente `.tres`) que armazenam informações de forma estruturada.

### SongData

Define a estrutura de dados que compõe uma música.

* **Responsabilidade:**
	* É um `Resource` com `class_name SongData`.
	* Agrupa todas as informações que uma música precisa:
		* `audio_stream`: O arquivo de áudio (ex: .ogg ou .mp3).
		* `name`: Nome da música.
		* `bpm`: Batidas Por Minuto.
		* `measure`: Compasso (ex: 4 para 4/4).
		* `initial_offset`: Atraso inicial em segundos antes da primeira batida.

* **Como usar?**
	* Para criar uma nova música, clique com o botão direito no FileSystem (ex: na pasta `songs/`), selecione `Novo > Resource...`, e na lista, procure e selecione `SongData`.
	* Salve o novo arquivo (ex: `minha_musica.tres`).
	* Selecione o arquivo e preencha os campos (BPM, AudioStream, etc.) no Inspetor.
	* Para que a música seja utilizável, adicione-a ao `SongDB.gd` (no `enum Song` e no `SONGS_UIDS`).

## Cenas Principais

### `bootloader.tscn`

* **Descrição:** A primeira cena que o Godot carrega ao iniciar o jogo.
* **Função:** Sua única função é garantir que os Autoloads sejam carregados. Imediatamente após carregar, o `SceneManager` é chamado para carregar a cena inicial (ex: `Menu`).

### `menu.tscn`

* **Descrição:** A cena do menu principal.
* **Função:** Demonstra o uso do `SceneManager` para navegar para outras cenas (como `RhythmTest`).

### `rhythm_test.tscn`

* **Descrição:** Uma cena de teste de ritmo.
* **Função:** Demonstra um exemplo prático de como `Conductor` e `InputJudge` funcionam juntos.
	* Carrega e inicia a música de teste.
	* Conecta-se ao sinal `beat_hit` para atualizar um `Label` com o tempo da música.
	* Conecta-se ao sinal `action_judged` para mudar a cor de um `ColorRect` (Verde para `HIT`, Vermelho para `MISS`).
