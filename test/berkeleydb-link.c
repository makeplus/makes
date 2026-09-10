#include <db.h>
#include <stdio.h>

int main(void) {
    int major, minor, patch;
    DB *db = NULL;
    puts(db_version(&major, &minor, &patch));
    if (major != DB_VERSION_MAJOR || minor != DB_VERSION_MINOR)
        return 1;
    if (db_create(&db, NULL, 0) != 0)
        return 2;
    return db->close(db, 0);
}
