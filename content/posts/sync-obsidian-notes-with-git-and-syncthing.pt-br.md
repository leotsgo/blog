+++
authors = "Leonardo Bermejo"
categories = ["Tech"]
tags = ["zettelkasten", "homelab"]
date = "2024-09-21"
title = "Sincronizando Notas do Obsidian Com Git e Syncthing"
slug = "sincronizando-notas-obsidian-git-syncthing"
+++

Fazer anotações e construir meu Zettelkasten está se tornando uma parte cada vez mais importante da minha vida. Com ele me torno capaz de refletir sobre meus sentimentos e meus aprendizados, fazendo conexões que não apareceriam de outra forma.

Um aspecto importante do hábito de tomar notas é a capacidade de fazer anotações em múltiplos dispositivos onde quer que eu esteja. Nesse artigo irei explicar como configurei a sincronização das minhas notas em diferentes dispositivos.

# O Problema

Em 2024, já é possível usar o Plugin do Git para Obsidian para fazer as sincronizações das notas no Android, porém [apenas via https](https://www.reddit.com/r/ObsidianMD/comments/17odzjb/obsidian_android_syncing_via_github_in_2023/). Como estou usando um repositório privado do Github para sincronizar minhas notas, não me senti confortável em ter uma _access key_ no meu telefone em um arquivo de texto puro.

# A Solução

Tenho um pequeno clone do RasperryPi chamado OrangePi. E se eu pudesse sincronizar um diretório do meu telefone como um diretório do meu OrangePi ? Eu poderia então apenas automatizar o processo de fazer commits e push no meu repositório, enquanto a integração com o telefone ficasse com outra ferramenta - O Syncthing.

# O Como

Para essa configuração vou assumir que você já tenha o git configurado na sua máquina e o [Syncthing](https://syncthing.net/) instalado. Após a instalação, temos que garantir que o Syncthing rodará como um [system service](https://docs.syncthing.net/users/autostart.html#how-to-set-up-a-system-service) e não um user service no systemd:

```bash
systemctl enable syncthing@myuser.service
systemctl start syncthing@myuser.service
```

Em que **myuser** é o nome de um usuário na sua máquina. Com isso feito, basta usar a interface gráfica do Syncthing para habilitar a integração com outros dispositivos. Não entrarei em detalhes já que existem muitos artigos explicando [como fazer](https://medium.com/linuxforeveryone/how-to-sync-all-your-stuff-with-syncthing-linux-android-guide-536fe61d68df) a integração usando o WebGUI. Basta ter o aplicativo do Syncthing no seu Android e seguir os passos.

Com a sincronização ativada, precisamos de um script pra ser executado por nosso serviço do systemd. Esse script faz pull do Github, commita as diferenças que existem localmente e em seguida faz o push:

```bash
#!/bin/bash

cd /home/youruser/sb
git pull
git add --all
git commit -m "manual backup: $(date '+%Y-%m-%d %H:%M:%S')"
git push
```

Coloquei esse script na home do meu usuário com o nome de **sync.sh**. É necessário dar permissão de execução para o script:
`chmod +x sync.sh`

Agora precisamos apenas configurar o serviço e o timer do systemd. No meu caso, rodo esse script uma vez por minuto, mas você pode usar a frequência que quiser.

Va até `/etc/systemd/system` e crie dois arquivos - `syncsb.service` and `syncsb.timer`. Os nomes não importam desde que você seja consistente com os nomes ao fazer os apontamentos nos arquivos. O serviço será responsável por rodar o script, e a execução só acontece quando o gatilho do timer ocorrer.

syncsb.service:

```bash
[Unit]
Description=Sync my notes

[Service]
Type=simple
User=myuser
Environment=HOME=/home/myuser
WorkingDirectory=/home/myuser/notes-repository
ExecStart=/home/myuser/sync.sh
Restart=on-failure

[Install]
WantedBy=default.target
```

Não se esqueça de passar corretamente o nome do usuário ou o script pode não ter privilégios para executar comandos git.

syncsb.timer:

```bash
[Unit]
Description=Sync notes every minute

[Timer]
OnUnitActiveSec=1min
Unit=syncsb.service

[Install]
WantedBy=timers.target
```

O campo **Unit** embaixo de **Timer** precisa ter o mesmo nome do seu serviço.

Com os arquivos criados, execute os seguintes comandos:

```bash
# Faz o reload do daemon para que os arquivos possam ser lidos
sudo systemctl daemon-reload

# habilita e inicia o serviço e o timer
sudo systemctl enable syncsb.timer
sudo systemctl enable syncsb.service
sudo systemctl start syncsb.timer
```

E feito! Dessa maneira todas as mudanças que você fizer em um dispositivo serão sincronizadas com os demais. Apenas tome cuidado para não editar um arquivo em mais de um dispositivo antes da sincronização acontecer.
