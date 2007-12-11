
set(CMAKE_INCLUDE_CURRENT_DIR ON)
INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/toolkit
    ${CMAKE_CURRENT_SOURCE_DIR}/mpeg
    ${CMAKE_CURRENT_SOURCE_DIR}/ogg
    ${CMAKE_CURRENT_SOURCE_DIR}/flac
    ${CMAKE_CURRENT_SOURCE_DIR}/mpc
    ${CMAKE_CURRENT_SOURCE_DIR}/ogg/vorbis
    ${CMAKE_CURRENT_SOURCE_DIR}/mpeg/id3v2
    ${CMAKE_CURRENT_SOURCE_DIR}/mpeg/id3v1
    ${CMAKE_CURRENT_SOURCE_DIR}/ape
    ${CMAKE_CURRENT_BINARY_DIR}/taglib
    ${CMAKE_CURRENT_BINARY_DIR}/..
    ${ZLIB_INCLUDE_DIR}
)

ADD_SUBDIRECTORY( toolkit )
ADD_SUBDIRECTORY( mpeg )
ADD_SUBDIRECTORY( ogg )
ADD_SUBDIRECTORY( flac )
ADD_SUBDIRECTORY( ape )
ADD_SUBDIRECTORY( mpc )



########### next target ###############

SET(mpeg_SRCS
mpeg/mpegfile.cpp
mpeg/mpegproperties.cpp
mpeg/mpegheader.cpp
mpeg/xingheader.cpp
)

SET(id3v1_SRCS
mpeg/id3v1/id3v1tag.cpp
mpeg/id3v1/id3v1genres.cpp
)


SET(id3v2_SRCS
mpeg/id3v2/id3v2framefactory.cpp
mpeg/id3v2/id3v2synchdata.cpp
mpeg/id3v2/id3v2tag.cpp
mpeg/id3v2/id3v2header.cpp
mpeg/id3v2/id3v2frame.cpp
mpeg/id3v2/id3v2footer.cpp
mpeg/id3v2/id3v2extendedheader.cpp
)


SET(frames_SRCS
mpeg/id3v2/frames/attachedpictureframe.cpp
mpeg/id3v2/frames/commentsframe.cpp
mpeg/id3v2/frames/generalencapsulatedobjectframe.cpp
mpeg/id3v2/frames/relativevolumeframe.cpp
mpeg/id3v2/frames/textidentificationframe.cpp
mpeg/id3v2/frames/uniquefileidentifierframe.cpp
mpeg/id3v2/frames/unknownframe.cpp
)

SET(ogg_SRCS
ogg/oggfile.cpp
ogg/oggpage.cpp
ogg/oggpageheader.cpp
ogg/xiphcomment.cpp
)

SET(vorbis_SRCS
ogg/vorbis/vorbisfile.cpp
ogg/vorbis/vorbisproperties.cpp
)


SET(flacs_SRCS
flac/flacfile.cpp
flac/flacproperties.cpp
)

SET(oggflacs_SRCS
ogg/flac/oggflacfile.cpp
)

SET(mpc_SRCS
mpc/mpcfile.cpp
mpc/mpcproperties.cpp
)

SET(ape_SRCS
ape/apetag.cpp
ape/apefooter.cpp
ape/apeitem.cpp
)

SET(toolkit_SRCS
toolkit/tstring.cpp
toolkit/tstringlist.cpp
toolkit/tbytevector.cpp
toolkit/tbytevectorlist.cpp
toolkit/tfile.cpp
toolkit/tdebug.cpp
toolkit/unicode.cpp
)

if(MP4V2_FOUND)
include_directories( ${MP4V2_INCLUDE_DIR} )
set(libtagmp4_SRCS
        mp4/mp4file.cpp
        mp4/mp4tag.cpp
        mp4/mp4properties.cpp
        mp4/taglib_mp4filetyperesolver.cpp
)
else(MP4V2_FOUND)
set(libtagmp4_SRCS
	m4a/taglib_mp4filetyperesolver.cpp
	m4a/mp4file.cpp
	m4a/mp4itunestag.cpp
	m4a/mp4isobox.cpp
	m4a/mp4isofullbox.cpp
	m4a/mp4skipbox.cpp
	m4a/mp4moovbox.cpp
	m4a/mp4mvhdbox.cpp
	m4a/mp4ilstbox.cpp
	m4a/boxfactory.cpp
	m4a/mp4fourcc.cpp
	m4a/mp4udtabox.cpp
	m4a/mp4metabox.cpp
	m4a/mp4tagsproxy.cpp
	m4a/mp4mdiabox.cpp
	m4a/mp4minfbox.cpp
	m4a/mp4audioproperties.cpp
	m4a/mp4hdlrbox.cpp
	m4a/mp4stblbox.cpp
	m4a/mp4audiosampleentry.cpp
	m4a/mp4stsdbox.cpp
	m4a/mp4sampleentry.cpp
	m4a/mp4trakbox.cpp
	m4a/mp4propsproxy.cpp
	m4a/itunesnambox.cpp
	m4a/itunesartbox.cpp
	m4a/itunesalbbox.cpp
	m4a/itunescvrbox.cpp
	m4a/itunesgenbox.cpp
	m4a/itunestrknbox.cpp
	m4a/itunesdaybox.cpp
	m4a/itunescmtbox.cpp
	m4a/itunesgrpbox.cpp
	m4a/ituneswrtbox.cpp
	m4a/itunesdiskbox.cpp
	m4a/itunestmpobox.cpp
	m4a/itunesdatabox.cpp
)
endif(MP4V2_FOUND)

set(libtagwav_SRCS
        wav/wavfile.cpp
        wav/wavproperties.cpp
        wav/wavfiletyperesolver.cpp
)

set(libtagtrueaudio_SRCS
        trueaudio/taglib_trueaudiofiletyperesolver.cpp
        trueaudio/ttafile.cpp
        trueaudio/ttaproperties.cpp
)

set(libtagwavpack_SRCS
        wavpack/taglib_wavpackfiletyperesolver.cpp
        wavpack/wvfile.cpp
        wavpack/wvproperties.cpp
)

set(libtagspeex_SRCS
        speex/speexfile.cpp
        speex/taglib_speexfiletyperesolver.cpp
        speex/speexproperties.cpp
)

set(libtagwma_SRCS
	wma/wmaattribute.cpp
	wma/wmaproperties.cpp
	wma/wmatag.cpp
	wma/wmafile.cpp
	wma/taglib_wmafiletyperesolver.cpp
)

set(libtagaac_SRCS
	aac/aacfiletyperesolver.cpp
)

set(libtagrealmedia_SRCS
	rmff/rmff.cpp
	rmff/taglib_realmediafile.cpp
	rmff/taglib_realmediafiletyperesolver.cpp
)


set(libtagaudible_SRCS
	audible/audibleproperties.cpp
	audible/audibletag.cpp
	audible/taglib_audiblefile.cpp
	audible/taglib_audiblefiletyperesolver.cpp
	)



SET(tag_LIB_SRCS 
	${mpeg_SRCS} 
	${id3v1_SRCS} 
	${id3v2_SRCS} 
	${frames_SRCS} 
	${ogg_SRCS}
	${vorbis_SRCS} 
	${oggflacs_SRCS} 
	${mpc_SRCS} 
	${ape_SRCS} 
	${toolkit_SRCS} 
	${flacs_SRCS}
        ${libtagmp4_SRCS}  # Extras from Amarok
        ${libtagaudible_SRCS}
	#        ${libtagrealmedia_SRCS}
        ${libtagaac_SRCS}
        ${libtagwma_SRCS}
        ${libtagwav_SRCS}
        ${libtagwavpack_SRCS}
        ${libtagspeex_SRCS}
        ${libtagtrueaudio_SRCS}
	tag.cpp
	tplugins.cpp
	fileref.cpp
	audioproperties.cpp
)


ADD_LIBRARY(tag SHARED ${tag_LIB_SRCS})

TARGET_LINK_LIBRARIES(tag )
if(ZLIB_FOUND)
	TARGET_LINK_LIBRARIES(tag ${ZLIB_LIBRARIES})
endif(ZLIB_FOUND)

SET_TARGET_PROPERTIES(tag PROPERTIES VERSION 1.4.0 SOVERSION 1 INSTALL_NAME_DIR ${LIB_INSTALL_DIR})
INSTALL(TARGETS tag DESTINATION ${LIB_INSTALL_DIR} )

INSTALL( FILES  tag.h fileref.h audioproperties.h DESTINATION ${INCLUDE_INSTALL_DIR}/taglib)
