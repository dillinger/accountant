let
    nixpkgs = import (builtins.fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz) {};
in

nixpkgs.mkShell {
  buildInputs = with nixpkgs; [
    git
    postgresql_15
  ];

  postgresConf =
    nixpkgs.writeText "postgresql.conf"
    ''
    # Add Custom Settings
    log_min_messages = warning
    log_min_error_statement = error
    log_min_duration_statement = 100  # ms
    log_connections = on
    log_disconnections = on
    log_duration = on
    #log_line_prefix = '[] '
    log_timezone = 'UTC'
    log_statement = 'all'
    log_directory = 'pg_log'
    log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
    logging_collector = on
    log_min_error_statement = error
    '';

    # ENV Variables
    # LD_LIBRARY_PATH = "${geos}/lib:${gdal}/lib";
    PGDATA = "${toString ./.}/.pg";

    # Post Shell Hook
    shellHook = ''
    echo "${nixpkgs.postgresql_15.name}."

    # Setup: other env variables
    export PGHOST="$PGDATA"
    # Setup: DB
    [ ! -d $PGDATA ] && pg_ctl initdb -o "-U postgres" && cat "$postgresConf" >> $PGDATA/postgresql.conf
    pg_ctl -o "-p 5555 -k $PGDATA" start
    alias fin="pg_ctl stop && exit"
    alias pg="psql -p 5555 -U postgres"
    '';
}
