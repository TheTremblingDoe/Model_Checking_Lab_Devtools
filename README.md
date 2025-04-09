# Лабораторная работа "Сравнение методов моделирования и верификации в nuXmv и SPIN"

![Главный герой моделей в репозитории.](https://github.com/TheTremblingDoe/Model_Checking_Lab_Devtools/blob/main/photo_2025-04-09_23-11-51.jpg)

## Языки моделирования

### SPIN
- **Promela (Process Meta Language)**: Язык, используемый в SPIN, ориентирован на моделирование параллельных систем. Основные объекты — процессы, переменные и каналы сообщений.
- **Процессы**: Описываются с помощью `proctype`, могут быть запущены с помощью `run` или `active`.
- **Каналы**: Используются для передачи данных между процессами, поддерживают синхронные и асинхронные коммуникации.
- **Выражения и операторы**: Поддерживаются различные типы данных и операторы, включая логические и арифметические.

### nuXmv
- **SMV (Symbolic Model Verifier)**: Язык, используемый в nuXmv, основан на синхронных системах.
- **Модули**: Основная структурная единица, содержит переменные состояния, начальные условия и отношения переходов.
- **Переменные**: Поддерживаются различные типы данных, включая булевы, целые, рациональные и массивы.
- **Отношения переходов**: Определяются с помощью `next()`, могут быть детерминированными или недетерминированными.

## Методы верификации

### SPIN
- **Model Checking**: Основной метод верификации, использует автоматы Бюхи для проверки свойств, выраженных в LTL (Linear Temporal Logic).
- **Assertions**: Локальные инварианты проверяются с помощью `assert`.
- **Never Claims**: Глобальные инварианты и свойства проверяются с помощью процесса `never`.
- **Свойства LTL**: Проверяются с помощью `ltl` спецификаций.

### nuXmv
- **Symbolic Model Checking**: Использует алгоритмы на основе SAT и SMT для проверки систем с конечным и бесконечным числом состояний.
- **Инварианты**: Проверяются с помощью `INVARSPEC`.
- **Свойства LTL и CTL**: Поддерживаются для проверки свойств в путях вычислений и деревьях вычислений соответственно.
- **Ограничения справедливости**: Поддерживаются для проверки свойств на честных путях.

## Возможности проверки свойств

### SPIN
- **LTL**: Поддержка линейной темпоральной логики для проверки свойств в путях вычислений.
- **Assertions и Never Claims**: Поддержка локальных и глобальных инвариантов.
- **Симмуляция**: Поддержка симуляции моделей для отладки и анализа.

### nuXmv
- **LTL и CTL**: Поддержка линейной и вычислительной темпоральной логики для проверки свойств.
- **Инварианты**: Поддержка инвариантных свойств.
- **Ограничения справедливости**: Поддержка справедливости `JUSTICE` и `COMPASSION` для проверки свойств на честных путях.

## Интересные особенности

В **NuXmv**, в отличие от используемого в SPIN языка Promela, должна соблюдаться жесткая иерархия модулей: всегда должен быть модуль `main`, и он всегда должен идти первым в тексте кода программы.

**SPIN**, в свою очередь, осуществляет промежуточную трансляцию в код на языке C, что теоретически может расширить возможности для его использования.

## Заключение

- **SPIN** больше ориентирован на асинхронные системы и поддерживает более гибкое моделирование процессов и каналов.
- **nuXmv** больше ориентирован на синхронные системы и поддерживает более сложные типы данных и отношения переходов, а также символьные методы верификации.

## Инструкция по запуску кода

В репозитории расположены модели одной и той же системы, созданные для NuXmv и SPIN. Для демонстрационного запуска нужно установить соотвествующие интрументы - поместить в директорию бинарные файлы SPIN и NuXmv, которые можно получить с официальных ресурсов.

**Для модели `model.smv` (nuXmv)**
```bash
./NuXmv model.smv
```

**Для модели `model.pml` (SPIN)**
```bash
spin -a model.pml
gcc -o pan pan.c
./pan -a -N property
```
Эти команды позволяют запустить верификацию моделей в соответствующих инструментах.

## Описание системы
Существует устройство (автоматическая кормушка для белок). При использовании устройства пользователю нужно выбрать один из двух видов орехов нажатием на отдельную кнопку на корпусе устройства. Затем пользователь производит оплату - 75 или 50 у.е. в зависимости от выбранного товара через банковский терминал. После этого некоторое количество орехов выдается пользователю через специльное отделение в устройстве.

Для этой системы нужно сформулировать 3 свойства в терминах логики LTL и проверить их с помощью верификаторов.

Требования к системе: система должна содержать процесс управляющего алгоритма, процессы датчиков/индикаторов, процессы актуаторов и процесс пользователя/среды. Система должна работать бесконечно за счёт обработки сигналов пользователя/среды, поступающих время от времени и недетерминированным образом.

![Результат](https://github.com/TheTremblingDoe/Model_Checking_Lab_Devtools/blob/main/photo_2025-04-09_23-11-58.jpg)

## Описание решения
### Краткий обзор деталей реализации
В моделях представлены:
- Процесс управляющего алгоритма -- main и Controller.
- Процесс актуаторов -- terminal и Dispenser.
- Процесс датчиков -- terminal и Controller.
- Процесс пользователя -- user и User.
Некоторые процессы специально объеденины в совместные сущности, чтобы облегчить понимание логики работы алгоритма.

### Сформулированные свойства
1. Пользователь всегда получит именно тот товар, который он оплатил, следующим шагом после оплаты.
2. Пользователь не может получить товар, если его нет в автомате.
3. Пользователь не может купить товар, если у него отсутствуют средства.
4. Пользователь должен оплатить именно тот товар, который он выбрал на предыдущем шаге.
