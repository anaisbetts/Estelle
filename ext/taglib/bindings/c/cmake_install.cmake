# Install script for directory: /Users/paul/Estelle-ruby/ext/taglib/bindings/c

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

FILE(INSTALL DESTINATION "/usr/local/lib" TYPE SHARED_LIBRARY PROPERTIES VERSION 0.0.0 SOVERSION 0 FILES "/Users/paul/Estelle-ruby/ext/taglib/bindings/c/libtag_c.dylib")
IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" MATCHES "^()$")
  EXECUTE_PROCESS(COMMAND install_name_tool
    -id "libtag_c.0.dylib"
    -change "/Users/paul/Estelle-ruby/ext/taglib/taglib/libtag.1.dylib" "/usr/local/lib/libtag.1.dylib"
    "$ENV{DESTDIR}/usr/local/lib/libtag_c.0.dylib")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" MATCHES "^()$")
FILE(INSTALL DESTINATION "/usr/local/lib/pkgconfig" TYPE FILE FILES "/Users/paul/Estelle-ruby/ext/taglib/bindings/c/taglib_c.pc")
FILE(INSTALL DESTINATION "/usr/local/include/taglib" TYPE FILE FILES "/Users/paul/Estelle-ruby/ext/taglib/bindings/c/tag_c.h")
