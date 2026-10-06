# База данных видеоплатформы



## Структура базы



| Таблица | Назначение | Тип связи с другими |

|---|---|---|

| `accounts` | Аккаунты пользователей | 1:M с `channels` |

| `channels` | Каналы | M:1 с `accounts`, 1:M с `videos`, 1:1 с `channel\_settings`, M:N с `channels` (подписки), M:N с `videos` (лайки) |

| `channel\_settings` | Настройки канала | 1:1 с `channels` |

| `videos` | Видео | M:1 с `channels`, 1:M с `comments`, M:N с `channels` (лайки) |

| `subscriptions` | Подписки каналов друг на друга | M:N между `channels` |

| `comments` | Комментарии к видео | M:1 с `videos`, M:1 с `channels` |

| `likes` | Лайки видео каналами | M:N между `channels` и `videos` |



## Типы связей



\- \*\*1:1\*\* — `channels` ↔ `channel\_settings`.

\- \*\*1:M\*\* — `accounts` → `channels`, `channels` → `videos`, `videos` → `comments`.

\- \*\*M:N\*\* — `channels` ↔ `channels` (через `subscriptions`),

&#x20; `channels` ↔ `videos` (через `likes`).



## Скриншоты



!\[Таблицы](screenshots/tables.png)



!\[Запрос 1](screenshots/1.png)





!\[Запрос 2](screenshots/2.png)





!\[Запрос 3](screenshots/3.png)





!\[Запрос 4](screenshots/4.png)



