#if !define(WIN32)
////////////////////////////////////////////////////////////////////////////////
// IcsPrintIcs

void IcsPrintIcs (ICS const* ics);
/* Prints the contents of the ICS structure to stdout (using only printf). */

////////////////////////////////////////////////////////////////////////////////
// IcsPrintError

void IcsPrintError (Ics_Error error);
/* Prints a textual representation of the error message to stdout (using
 * only printf). */
#endif
