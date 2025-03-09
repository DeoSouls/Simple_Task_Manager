# Этап сборки
FROM ubuntu:22.04 AS builder

# Установка зависимостей
RUN apt-get update && apt-get install -y ... 

# Установка Qt (используйте aqtinstall или актуальный URL)
RUN pip install aqtinstall && \
    aqt install-qt linux desktop 6.8.1 -O /opt/qt ...

# Настройка окружения Qt
ENV PATH="/opt/qt/6.8.1/gcc_64/bin:${PATH}"
ENV CMAKE_PREFIX_PATH="/opt/qt/6.8.1/gcc_64/lib/cmake"
ENV QT_QPA_PLATFORM="offscreen"

# Сборка проекта
WORKDIR /app
COPY . .
RUN mkdir -p build && cd build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DQT_HOST_PATH=/opt/qt/6.8.1/gcc_64 && \
    cmake --build . --parallel $(nproc) --target install

# Этап выполнения
FROM ubuntu:22.04

# Установка зависимостей времени выполнения
RUN apt-get update && apt-get install -y ...

# Копирование приложения и библиотек Qt
COPY --from=builder /usr/bin/appSimpleTaskManager /app/
COPY --from=builder /opt/qt/6.8.1/gcc_64/plugins /opt/qt/plugins
COPY --from=builder /opt/qt/6.8.1/gcc_64/lib /opt/qt/lib

# Инициализация LD_LIBRARY_PATH (добавьте эту строку)
ENV LD_LIBRARY_PATH="/opt/qt/lib:${LD_LIBRARY_PATH:-}"
ENV QT_QPA_PLATFORM_PLUGIN_PATH="/opt/qt/plugins/platforms"
WORKDIR /app
CMD ["./appSimpleTaskManager"]

