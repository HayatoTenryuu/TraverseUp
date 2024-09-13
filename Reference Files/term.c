/* Include libraries. */
#include <stdio.h>
#include <string.h>
#include <SWI-Prolog.h>

/* Main */
int main(int argc, char **argv)                                                 // Get (arg_count = count of arg_vector characters) and (arg_vector pointer = pointer to input char array)
{ 
    /*-----------------------*/
    /*         Setup         */
    /*-----------------------*/

    char expression[1024];                                                      // Create character array with a max number of characters.
    char *e = expression;                                                           // Create a pointer to that array.
    char *program = argv[0];                                                        // Create a pointer to the input characters.
    char *plav[2];                                                                  // Create an array of pointers (the argument vector for Prolog).

  /* Combine all the arguments in a single string */
    for(int n=1; n<argc; n++)                                                   // Copy every character in argv to expression (via copying the address of every value in argv to the pointer e).
    { 
        if ( n != 1 )
        {
            *e++ = ',';                                                             // Add spaces between each character after the first one.
            *e++ = ' ';
        }
        strcpy(e, argv[n]);                                                         // Copy every address of argv[n] to e.
        e += strlen(e);                                                             // Move e to the next location in memory which is free to store stuff.
    }

    /* Make the argument vector for Prolog */
    plav[0] = program;                                                          // The first argv for Prolog is location of the first argv passed from the terminal.
    plav[1] = NULL;                                                             // NULL ends the execution.

    /*-------------------------------------------------------*/
    /* Section for debugging inputs before they reach Prolog */
    /*-------------------------------------------------------*/

    char* argz;
    char* argy[2];
    argz = strtok(expression, ",");

    /*printf("\n");
    printf(expression);
    printf("\n");
    printf(argz);
    printf("\n");*/

    for (int a = 0; argz != NULL; a++)
    {
        argy[a] = argz;
        argz = strtok(NULL, ",");
    }

    /*printf("\n");
    printf("%s", argy[0]);
    printf("%s", argy[1]);
    printf("\n");*/
    

    /*-----------------------*/
    /*     Prolog Parts      */                                                     
    /*-----------------------*/

    /* Initialise Prolog */
    if ( !PL_initialise(1, plav) )                                              // Kill Prolog if it doesn't initialize successfully.
    {
        PL_halt(1);
    }
    
    /* Define the function(s) we wish to call from Prolog. */
    predicate_t pred = PL_predicate("traverseUp", 3, "user");                   // Call traverseUp/3 with user settings.

    /* Define the argument(s) we wish to pass to the function(s). */
    term_t h0 = PL_new_term_refs(3);                                            // Create term h0.
    term_t h1 = h0+1;                                                           // Create term h1.

    PL_put_atom_chars(h0, argy[0]);                                             // Put the first argument as an atom in h0.
    PL_put_atom_chars(h1, argy[1]);                                             // Put the second argument as an atom in h1.

    /* Call Prolog and execute the function. */
    int ret_val = PL_call_predicate(NULL, PL_Q_NORMAL, pred, h0);               // Call pred with input h0, and return the ret_val, with NULL context module and normal flags

    PL_halt(ret_val ? 0 : 1);                                                   // Close Prolog (return 0 if good, or return 1 if error)

  return 0;
}