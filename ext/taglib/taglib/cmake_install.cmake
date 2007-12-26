# Install script for directory: /Users/paul/Estelle-ruby/ext/taglib/taglib

# Set the install prefix
IF(NOT DEFINED CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "/usr/local")
ENDIF(NOT DEFINED CMAKE_INSTALL_PREFIX)
STRING(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
IF(NOT CMAKE_INSTALL_CONFIG_NAME)
  IF(BUILD_TYPE)
    STRING(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  ELSE(BUILD_TYPE)
    SET(CMAKE_INSTALL_CONFIG_NAME "")
  ENDIF(BUILD_TYPE)
  MESSAGE(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
ENDIF(NOT CMAKE_INSTALL_CONFIG_NAME)

# Set the component getting installed.
IF(NOT CMAKE_INSTALL_COMPONENT)
  IF(COMPONENT)
    MESSAGE(STATUS "Install component: \"${COMPONENT}\"")
    SET(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  ELSE(COMPONENT)
    SET(CMAKE_INSTALL_COMPONENT)
  ENDIF(COMPONENT)
ENDIF(NOT CMAKE_INSTALL_COMPONENT)

FILE(INSTALL DESTINATION "/usr/local/lib" TYPE SHARED_LIBRARY PROPERTIES VERSION 1.4.0 SOVERSION 1 FILES "/Users/paul/Estelle-ruby/ext/taglib/taglib/libtag.dylib")
IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" MATCHES "^()$")
  EXECUTE_PROCESS(COMMAND install_name_tool
    -id "/usr/local/lib/libtag.1.dylib"
    "$ENV{DESTDIR}/usr/local/lib/libtag.1.dylib")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" MATCHES "^()$")
FILE(INSTALL DESTINATION "/usr/local/include/taglib" TYPE FILE FILES "/Users/paul/Estelle-ruby/ext/taglib/taglib/tag.h")
FILE(INSTALL DESTINATION "/usr/local/include/taglib" TYPE FILE FILES "/Users/paul/Estelle-ruby/ext/taglib/taglib/fileref.h")
FILE(INSTALL DESTINATION "/usr/local/include/taglib" TYPE FILE FILES "/Users/paul/Estelle-ruby/ext/taglib/taglib/audioproperties.h")
IF(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  INCLUDE("/Users/paul/Estelle-ruby/ext/taglib/taglib/toolkit/cmake_install.cmake")
  INCLUDE("/Users/paul/Estelle-ruby/ext/taglib/taglib/mpeg/cmake_install.cmake")
  INCLUDE("/Users/paul/Estelle-ruby/ext/taglib/taglib/ogg/cmake_install.cmake")
  INCLUDE("/Users/paul/Estelle-ruby/ext/taglib/taglib/flac/cmake_install.cmake")
  INCLUDE("/Users/paul/Estelle-ruby/ext/taglib/taglib/ape/cmake_install.cmake")
  INCLUDE("/Users/paul/Estelle-ruby/ext/taglib/taglib/mpc/cmake_install.cmake")

ENDIF(NOT CMAKE_INSTALL_LOCAL_ONLY)
