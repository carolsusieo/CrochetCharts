#
# This file contains functions to generate documentaion from docbook files.
# TODO: make sure that docbook-xsl-ns package is installed
# by: Brian C. Milco <bcmilco@gmail.com>
#
#FORMATS:
#html: generic html
#pdf: a PDF
#pages: Mac specific html help pages
#htmlhelp: MS Windows specific html help pages

function(DOCBOOK_GENERATE format input version)

    set(working "${CMAKE_CURRENT_BINARY_DIR}/${format}")
    make_directory(${working})

    file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/images DESTINATION ${working})

    if(APPLE)
        set(xsltproc "/usr/bin/xsltproc")
        set(fop "/opt/fop/fop")
        set(docbookBasePath "/usr/share/xml/docbook/stylesheet/docbook-xsl-ns")
    elseif(WIN32)
        set(xsltproc "C:\\cygwin\\opt\\bin\\xsltproc")
        set(fop "C:\\cygwin\\opt\\fop\\fop")
        set(docbookBasePath "C:\\cygwin\\usr\\share\\xml\\docbook\\stylesheet\\docbook-xsl-ns")
    else()
        set(xsltproc "/usr/bin/xsltproc")
        set(fop "/usr/bin/fop")
        set(docbookBasePath "/usr/share/xml/docbook/stylesheet/docbook-xsl-ns")
    
    endif()

message("xsl:" ${xsltproc})
message("fop:" ${fop})
message("doc:" ${docbookBasePath})
    if(format STREQUAL "html")
            set(xslFile "${docbookBasePath}/html/docbook.xsl")

            #TODO: include a custom CSS Style sheet:
            #file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/mystyle.css DESTINATION ${working})
            #--stringparam html.stylesheet mystyle.css

            execute_process(
                COMMAND "${xsltproc}" --xinclude -o "${working}/index.html" "${xslFile}" "${input}"
                OUTPUT_FILE "${working}/index.html"
                OUTPUT_VARIABLE _output)

        
    elseif(format STREQUAL "pdf")

            set(outputBaseName "${working}/${PROJECT_NAME}_User_Guide_${version}")

            set(xslFile "${CMAKE_CURRENT_SOURCE_DIR}/mystyle.xsl")

            execute_process(
                COMMAND "${xsltproc}" -o "${outputBaseName}.fo" --stringparam fop1.extensions 1 ${xslFile} "${input}"
                OUTPUT_FILE "${outputBaseName}.fo"
                OUTPUT_VARIABLE _output)

            execute_process(
                COMMAND "${fop}" -fo "${outputBaseName}.fo" -pdf "${outputBaseName}.pdf"
                OUTPUT_FILE "${outputBaseName}.pdf"
                OUTPUT_VARIABLE _output)

    elseif(format STREQUAL "pages")
            set(xslFile "${docbookBasePath}/roundtrip/dbk2pages.xsl")
            set(outputFile "${working}/index.xml")

            execute_process(
                COMMAND "${xsltproc}" -o "${outputFile}" --stringparam pages.template template-pages.xml ${xslFile} "${input}"
                OUTPUT_FILE "${outputFile}"
                OUTPUT_VARIABLE _output)
            
    elseif(format STREQUAL "htmlhelp")
            set(xslFile "${docbookBasePath}/htmlhelp/htmlhelp.xsl")
            
            execute_process(
                COMMAND "/usr/bin/xsltproc" ${xslFile} "${input}"
                WORKING_DIRECTORY "${working}"
                OUTPUT_VARIABLE _output)
        
    else()
        message ( FATAL_ERROR "Unsupported output format." )

    endif()

    set(${outList} ${${outList}} PARENT_SCOPE)

endfunction()
