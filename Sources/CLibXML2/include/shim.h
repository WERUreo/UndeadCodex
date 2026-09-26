#include <libxml/parser.h>
#include <libxml/xpath.h>

static inline void lg_xmlFree(void *memory) {
    xmlFree(memory);
}