#### Simple OPDS Catalog - Простой OPDS Каталог  
#### Author: Dmitry V.Shelepnev  
#### Версия 0.19  

#### 1. Установка Simple OPDS в Fedora, RedHat, CentOS:    

1.1 Зависимости.  
Требуется Mysql не ниже версии 5 (необходима поддержка хранимых процедур)  
Требуется Python не ниже версии 3.3 (используется атрибут zlib.Decompressor.eof, введенный в версии 3.3)  

Для работы проекта необходимо установить следующие зависимости:  

     yum install httpd  
     yum install mysql  
     yum install python3  
     yum install mysql-connector-python3  

1.2 Установка.  
Загрузить проект можно с сайта www.sopds.ru.  
Проект имеет следующую структуру:  

>opds			- каталог проекта (можно задать свое имя каталога)  
>    py			- каталог с программами на Python  
>    db			- каталог инициализационные скрипты для создания БД  
>    conf		- каталог с файлом конфигурации  
>    README.md		- файл README  

1.3 Конфигурационный файл.  
Перед началом работы необходимо внести необходимые настройки в файл конфигурации ./conf/sopds.conf  

1.4 Инициализация базы данных.  
Во первых для работы каталога необходимо создать базу данных "sopds" и пользователя с необходимыми правами,  
например следующим образом:  

     mysql -uroot -proot_pass mysql  
     mysql > create database if not exists sopds default charset=utf8;  
     mysql > grant select,insert,update,delete,execute on sopds.* to 'sopds'@'localhost' identified by 'sopds';  
     mysql > commit;  
     mysql > ^C  

Далее в созданную базу данных необходимо загрузить структуру БД и заполненную таблицу жанров, например 
следующим образом:  

     mysql -uroot -proot_pass sopds < ./db/tables.sql  
     mysql -uroot -proot_pass sopds < ./db/genres.sql  

Все указанные выше процедуры могут быть выполнены при помощи скрипта ./db/db_create.sh суперпользователем root (для Fedora)  

1.5 Использование OPDS-сервера.  
OPDS-Сервер запускается командой:  

     ./sopdsd.py start  

Указанная команда запустит два процесса в режиме демона Linux: 
- Демон сканирования, который будет производить периодическое сканирование Вашей коллекции книг на основании настроек в 
  секции [scand] конфигурационного файла  
- Демон http-opds-сервера, который предоставит доступ к коллекции книг OPDS-клиентам (по умолчанию прослушивается порт 8081)
  на основании настроек в секции [httpd] конфигурационного файла. Доступ к OPDS-каталогу в этом случае можно получить 
  по адресу http://<Ваш Сервер>:8081/  

> Команда ./sopdsd.py stop    - приведет к остановке обеих процессов  
> Команда ./sopdsd.py status  - покажет информацию о состоянии процессов  

  Собственно модуль sopdsd.py предоставляет все возможности пакета Simple OPDS и в большинстве случаев достаточно использовать
  только его.

  Для пользователей, которые по каким-то причинам желают обновлять БД SOPDS вручную в пакете присутствует
  программа однократного сканирования коллекции книг: sopds-scan.py

  Для доступа к коллекции книг, при желании можно использовать внешний HTTP-сервер, такой как Apache, или Nginx для этого в
  пакете программ присутсвуют скрипты:
  - sopds.cgi для использования технологии CGI (смотри раздел Базовая настройка CGI в сервере Apache)
  - sopds.wsgi для использования технологии WSGI (см. раздел Базовая настройка WSGI в сервере Apache)

1.6 Обновление версий
- Поскольку при переходе от версии к версии возможно изменение структуры БД необходимо пересоздать ее следующей командой
  ./db/db_create.sh либо выполнить рекомендации в п.4 

#### 2. Настройка конвертации fb2 в EPUB или MOBI (опционально, можно не настраивать)  

2.1 Конвертер fb2-to-epub http://code.google.com/p/fb2-to-epub-converter/
- во первых необходимо скачать последнюю версию конвертера fb2toepub по ссылке выше (текущая уже находится в проекте)
  к сожалению конвертер не совершенный и не все книги может конвертирвать, но большинство все-таки конвертируется 
- далее, необходимо скопировать архив в папку opds/fb2toepub и разархивировать 
- далее, компилируем проект командой make, в результате в папке  unix_dist появится исполняемый файл fb2toepub 
- в конфигурационном файле sopds.conf необходимо задать путь к этому конвертеру, а также путь к временной папке, 
  куда будут помещаться сконвертированные файлы, например таким образом:  

>     fb2toepub=../fb2toepub/unix_dist/fb2toepub
>     temp_dir=/tmp

- В результате OPDS-клиенту будут предоставлятся ссылки на FB2-книгу в формате epub  

2.2 Конвертер fb2epub http://code.google.com/p/epub-tools/ (конвертер написан на Java, так что в вашей системе должнен быть установлен как минимум JDK 1.5)  
- также сначала скачать последнюю версию по ссылке выше (текущая уже находится в проекте)  
- скопировать jar-файл например в каталог opds/fb2epub (Здесь уже лежит shell-скрипт для запуска jar-файла)  
- Соответственно прописать пути в файле конфигурации sopds.conf к shell-скрипту fb2epub  

>     fb2toepub=../fb2epub/fb2epub
>     temp_dir=/tmp

2.3 Конвертер fb2conv (конвертация в epub и mobi) http://www.the-ebook.org/forum/viewtopic.php?t=28447  
- Необходимо установить python 2.7 и пакеты lxml, cssutils:   
  
         yum install python  
         yum install python-lxml  
         yum install python-cssutils  
  
- скачать последнюю версию конвертера по ссылке выше (текущая уже находится в каталоге fb2conv проекта)  
- скачать утилиту KindleGen с сайта Amazon http://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000234621 
  (текущая версия утилиты уже находится в каталоге fb2conv проекта)  
- скопировать архив проекта в opds/fb2conv (Здесь уже подготовлены shell-скрипты для запуска конвертера) и разархивировать его  
- Для конвертации в MOBI нужно архив с утилитой KindleGen положить в каталог с конвертером и разархивировать  
- В конфигурационном файле sopds.conf задать пути к соответствующим скриптам:  

>     fb2toepub=../fb2conv/fb2epub  
>     fb2tomobi=../fb2conv/fb2mobi  
>     temp_dir=/tmp  


#### 3. Базовая настройка CGI в сервере Apache  
- Для работы CGI-скрипта необходимо разрешить доступ к каталогу opds, например при помощи следующих директив конфигурационного 
  файла web-сервера Apache httpd.conf:  

         <Directory "/home/www/opds">  
            Options Indexes FollowSymLinks  
            AllowOverride All  
            Order allow,deny  
            Allow from all  
         </Directory>  
         Alias   /opds           "/home/www/opds"  

- Далее, необходимо разрешить запуск cgi-скрипта ./py/sopds.cgi
  при помощи директив, помещенных в файл .htaccess, который необходимо создать в корне пакета SOPDS
  (например: /home/www/opds/.htaccess)  

         Options ExecCGI  
         AddHandler cgi-script .cgi  

- Для настройки аутентификации, создайте пользователя командой:  
  
         htpasswd -c /home/www/opds/.htpasswd user  
  
  и добавьте в .htaccess следующие строки:  

         AuthType Basic   
         AuthName "SOPDS Library"  
         AuthUserFile /home/www/opds/.htpasswd  
         require valid-user  
  
- при выполнении указанных выше процедур доступ к OPDS-каталогу можно получить по следующему адресу:  

>      http://<Ваш Сервер>/opds/py/sopds.cgi

- для сокращения URL доступа добавьте следующую директиву в файл .htaccess:  

         DirectoryIndex index.xml py/sopds.cgi  

  при использовании указанной директивы доступ к OPDS-каталогу можно получить по следующему адресу:  

>      http://<Ваш Сервер>/opds/


#### 4. Базовая настройка WSGI в сервере Apache  
WSGI - Web Server Gateway Interface - более эффективный стандарт взаимодействия Python программ с Веб сервером, чем CGI
WSGI в отличие от CGI позволяет не загружать интерпертатор Python со скриптом каждый раз, когда происходит обращение к
CGI-скрипту. Вместо этого Python-программа загружается однократно и выполняется при помощи постоянно загруженного модуля
mod_wsgi.  

4.1 Установка mod_wsgi  
- Для работы WSGI скрипта необходимо загрузить, скомпилировать и установить модуль mod_wsgi для Apache. Ньюанс тут только в том, 
  что нужный нам mod_wsgi должен быть скомпилирован для python3. Таких, уже готовых модулей я для своей системы не нашел, поэтому
  пришлось выполнить несложные шаги для компиляции нужного нам модуля:  
      
          yum install hg                                     # Устанавливаем клинета для Mercurial на которой ведется разработка mod_wsgi  
          hg clone https://code.google.com/p/modwsgi/        # Скачиваем исходники mod_wsgi  
          cd ./modwsgi/mod_wsgi  
          ./configure --with-python=/usr/bin/python3.3       # Конфигурим под наш Python3  
          make                                               # Компилируем  
          make install                                       # Устанавливаем  

- Прописываем в конфигурационный файл нашего сервера Apache следующую строку (Возможно она уже там есть)  

          LoadModule wsgi_module modules/mod_wsgi.so  

4.2 Настройка разрешений на запуск wsgi-скрипта делается аналогично настройке для CGI скрипта, т.е необходимо добавить в
файл .htaccess, следующие строки:  

         Options ExecCGI  
         AddHandler wsgi-script .wsgi  

- при выполнении указанных выше процедур доступ к OPDS-каталогу можно получить по следующему адресу:  

>      http://<Ваш Сервер>/opds/py/sopds.wsgi  

- для сокращения URL доступа добавьте следующую директиву в файл .htaccess:  

         DirectoryIndex index.xml py/sopds.wsgi  

  при использовании указанной директивы доступ к OPDS-каталогу можно получить по следующему адресу:  

>      http://<Ваш Сервер>/opds/  

4.3 Возможные проблемы.  
Одна из выявленных мной проблем совместимости скрипта sopds.wsgi с веб-сервером Apache состоит в том, что и SOPDS и Apache 
используют библиотеку "libexpat". И если версия libexpat, загруженная сервером Apache сильно отличается от той, которую 
нужна Питону, то происходит crash приложения sopds.wsgi.      
Подробное описание этой проблемы и возможных путей решений находится здесь:  

>      https://code.google.com/p/modwsgi/wiki/IssuesWithExpatLibrary  

Что в итоге сделал я:  
Удалил сиволические ссылки на старую библиотеку libexpat из каталога модулей сервера Apache:  

         unlink /usr/local/apache2/lib/libexpat.so  
         unlink /usr/local/apache2/lib/libexpat.so.0  

А затем создал новые на ту библиотеку, которая используется Питоном:  
           
         ln -s /usr/lib/libexpat.so.1.6.0 /usr/local/apache2/lib/libexpat.so  
         ln -s /usr/lib/libexpat.so.1.6.0 /usr/local/apache2/lib/libexpat.so.0  

Ну и перезагрузил Apache.  

