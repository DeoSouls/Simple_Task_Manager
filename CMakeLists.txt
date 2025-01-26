cmake_minimum_required(VERSION 3.16)

project(SimpleTaskManager VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Network Sql Widgets)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appSimpleTaskManager
    src/main.cpp
)

qt_add_qml_module(appSimpleTaskManager
    URI SimpleTaskManager
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES server/taskmanagerserver.h server/taskmanagerserver.cpp
        QML_FILES HomePage/Home.qml
        RESOURCES resource.qrc
        QML_FILES HomePage/ProjectListing.qml
        QML_FILES MenuPage/MainMenu.qml
        QML_FILES SettingsPage/Settings.qml
        SOURCES server/requesttask.h server/requesttask.cpp
        SOURCES server/sessionmanager.h server/sessionmanager.cpp
        SOURCES src/client.h src/client.cpp
        QML_FILES LoginPage/Login.qml
        QML_FILES SignUpPage/SignUp.qml
        QML_FILES common/CustomTextField.qml
        QML_FILES common/ErrorPopup.qml
        QML_FILES common/CustomButton.qml
        SOURCES server/clienthandler.h server/clienthandler.cpp
        QML_FILES common/Search.qml
        QML_FILES common/Tab.qml
        QML_FILES SpacePage/Space.qml
        QML_FILES common/CustomMenu.qml
        QML_FILES SpacePage/CreateTaskForm.qml
        QML_FILES common/CustomCalendar.qml
        QML_FILES common/SpaceTab.qml
        SOURCES src/tasksmodel.h src/tasksmodel.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appSimpleTaskManager PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appSimpleTaskManager
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appSimpleTaskManager
    PRIVATE Qt6::Quick Qt6::Network Qt6::Sql Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS appSimpleTaskManager
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
