/*
  LZ4cli - LZ4 Command Line Interface
  Copyright (C) Yann Collet 2011-2015

  GPL v2 License

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

  You can contact the author at :
  - LZ4 source repository : https://github.com/Cyan4973/lz4
  - LZ4 public forum : https://groups.google.com/forum/#!forum/lz4c
*/
/*
  Note : this is stand-alone program.
  It is not part of LZ4 compression library, it is a user program of the LZ4 library.
  The license of LZ4 library is BSD.
  The license of xxHash library is BSD.
  The license of this compression CLI program is GPLv2.
*/


/**************************************
*  Compiler Options
***************************************/

#define _POSIX_SOURCE 1        /* for fileno() within <stdio.h> on unix */


/****************************
*  Includes
*****************************/
#include <stdio.h>    /* fprintf, getchar */
#include <stdlib.h>   /* exit, calloc, free */
#include <string.h>   /* strcmp, strlen */
#include "lz4io.h"    /* LZ4IO_compressFilename, LZ4IO_decompressFilename, LZ4IO_compressMultipleFilenames */
#include <unistd.h>   /* isatty */
#define IS_CONSOLE(stdStream) isatty(fileno(stdStream))

/*****************************
*  Constants
******************************/
#define COMPRESSOR_NAME "LZ4 command line interface"
#ifndef LZ4_VERSION
#  define LZ4_VERSION "r128"
#endif
#define AUTHOR "Yann Collet"
#define WELCOME_MESSAGE "*** %s %i-bits %s, by %s (%s) ***\n", COMPRESSOR_NAME, (int)(sizeof(void*)*8), LZ4_VERSION, AUTHOR, __DATE__
#define LZ4_EXTENSION ".lz4"
#define LZ4CAT "lz4cat"
#define UNLZ4 "unlz4"

/**************************************
*  Macros
***************************************/
#define DISPLAY(...)           fprintf(stderr, __VA_ARGS__)
#define DISPLAYLEVEL(l, ...)   if (displayLevel>=l) { DISPLAY(__VA_ARGS__); }
static unsigned displayLevel = 1;   /* 0 : no display ; 1: errors only ; 2 : downgradable normal ; 3 : non-downgradable normal; 4 : + information */


/**************************************
*  Local Variables
***************************************/
static char* programName;


/**************************************
*  Exceptions
***************************************/
#define DEBUG 0
#define DEBUGOUTPUT(...) if (DEBUG) DISPLAY(__VA_ARGS__);
#define EXM_THROW(error, ...)                                             \
{                                                                         \
    DEBUGOUTPUT("Error defined at %s, line %i : \n", __FILE__, __LINE__); \
    DISPLAYLEVEL(1, "Error %i : ", error);                                \
    DISPLAYLEVEL(1, __VA_ARGS__);                                         \
    DISPLAYLEVEL(1, "\n");                                                \
    exit(error);                                                          \
}


/**************************************
*  Version modifiers
***************************************/
#define DEFAULT_COMPRESSOR   LZ4IO_compressFilename_Legacy
#define DEFAULT_DECOMPRESSOR LZ4IO_decompressFilename
int LZ4IO_compressFilename_Legacy(const char* input_filename, const char* output_filename, int compressionlevel);   /* hidden function */


/*****************************
*  Functions
*****************************/
static int usage(void)
{
    DISPLAY( "Usage :\n");
    DISPLAY( "      %s [arg] [input] [output]\n", programName);
    DISPLAY( "\n");
    DISPLAY( "input   : a filename\n");
    DISPLAY( "          with no FILE, or when FILE is - or %s, read standard input\n", stdinmark);
    DISPLAY( "Arguments :\n");
    DISPLAY( " -1     : Fast compression (default) \n");
    DISPLAY( " -9     : High compression \n");
    DISPLAY( " -d     : decompression (default for %s extension)\n", LZ4_EXTENSION);
    DISPLAY( " -z     : force compression\n");
    DISPLAY( " -f     : overwrite output without prompting \n");
    DISPLAY( " -h     : display help and exit\n");
    return 0;
}

static int badusage(void)
{
    DISPLAYLEVEL(1, "Incorrect parameters\n");
    if (displayLevel >= 1) usage();
    exit(1);
}

int main(int argc, char** argv)
{
    int i,
        cLevel=0,
        decode=0,
        forceStdout=0,
        forceCompress=0,
        operationResult=0;
    const char* input_filename=0;
    const char* output_filename=0;
    char* dynNameSpace=0;
    char nullOutput[] = NULL_OUTPUT;
    char extension[] = LZ4_EXTENSION;

    /* Init */
    programName = argv[0];
    LZ4IO_setOverwrite(0);

    /* lz4cat predefined behavior */
    if (!strcmp(programName, LZ4CAT)) { decode=1; forceStdout=1; output_filename=stdoutmark; displayLevel=1; }
    if (!strcmp(programName, UNLZ4)) { decode=1; }

    /* command switches */
    for(i=1; i<argc; i++)
    {
        char* argument = argv[i];

        if(!argument) continue;   /* Protection if argument empty */

        /* Short commands (note : aggregated short commands are allowed) */
        if (argument[0]=='-')
        {
            /* '-' means stdin/stdout */
            if (argument[1]==0)
            {
                if (!input_filename) input_filename=stdinmark;
                else output_filename=stdoutmark;
            }

            while (argument[1]!=0)
            {
                argument ++;
                if ((*argument>='0') && (*argument<='9'))
                {
                    cLevel = 0;
                    while ((*argument >= '0') && (*argument <= '9'))
                    {
                        cLevel *= 10;
                        cLevel += *argument - '0';
                        argument++;
                    }
                    argument--;
                    continue;
                }

                switch(argument[0])
                {
                    /* Display help */
		case 'h': usage(); goto _cleanup;
		case 'V': DISPLAY(WELCOME_MESSAGE); goto _cleanup;

                    /* Compression (default) */
                case 'z': forceCompress = 1; break;

                    /* Decoding */
                case 'd': decode=1; break;

                    /* Force stdout, even if stdout==console */
                case 'c': forceStdout=1; output_filename=stdoutmark; displayLevel=1; break;

                    /* Overwrite */
                case 'f': LZ4IO_setOverwrite(1); break;

                    /* Unrecognised command */
                default : badusage();
                }
            }
            continue;
        }

        /* Store first non-option arg in input_filename to preserve original cli logic. */
        if (!input_filename) { input_filename=argument; continue; }

        /* Second non-option arg in output_filename to preserve original cli logic. */
        if (!output_filename)
        {
            output_filename=argument;
            if (!strcmp (output_filename, nullOutput)) output_filename = nulmark;
            continue;
        }
    }

    /* No input filename ==> use stdin */
    if(!input_filename) { input_filename=stdinmark; }

    /* Check if input is defined as console; trigger an error in this case */
    if (!strcmp(input_filename, stdinmark) && IS_CONSOLE(stdin) ) badusage();

    /* No output filename ==> try to select one automatically (when possible) */
    while (!output_filename)
    {
        if (!IS_CONSOLE(stdout)) { output_filename=stdoutmark; break; }   /* Default to stdout whenever possible (i.e. not a console) */
        if ((!decode) && !(forceCompress))   /* auto-determine compression or decompression, based on file extension */
        {
            size_t l = strlen(input_filename);
            if (!strcmp(input_filename+(l-4), LZ4_EXTENSION)) decode=1;
        }
        if (!decode)   /* compression to file */
        {
            size_t l = strlen(input_filename);
            dynNameSpace = (char*)calloc(1,l+5);
			if (dynNameSpace==NULL) exit(1);
            strcpy(dynNameSpace, input_filename);
            strcat(dynNameSpace, LZ4_EXTENSION);
            output_filename = dynNameSpace;
            break;
        }
        /* decompression to file (automatic name will work only if input filename has correct format extension) */
        {
            size_t outl;
            size_t inl = strlen(input_filename);
            dynNameSpace = (char*)calloc(1,inl+1);
            strcpy(dynNameSpace, input_filename);
            outl = inl;
            if (inl>4)
                while ((outl >= inl-4) && (input_filename[outl] ==  extension[outl-inl+4])) dynNameSpace[outl--]=0;
            if (outl != inl-5) { DISPLAYLEVEL(1, "Cannot determine an output filename\n"); badusage(); }
            output_filename = dynNameSpace;
        }
    }

    /* Check if output is defined as console; trigger an error in this case */
    if (!strcmp(output_filename,stdoutmark) && IS_CONSOLE(stdout) && !forceStdout) badusage();

    /* Downgrade notification level in pure pipe mode (stdin + stdout) and multiple file mode */
    if (!strcmp(input_filename, stdinmark) && !strcmp(output_filename,stdoutmark) && (displayLevel==2)) displayLevel=1;

    /* IO Stream/File */
    LZ4IO_setNotificationLevel(displayLevel);
    if (decode)
    {
      DEFAULT_DECOMPRESSOR(input_filename, output_filename);
    }
    else
    {
      /* compression is default action */
      DEFAULT_COMPRESSOR(input_filename, output_filename, cLevel);
    }

_cleanup:
    free(dynNameSpace);
    return operationResult;
}
