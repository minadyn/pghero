module PgHero
  module Methods
    module Kill
      def kill(pid)
        PgHero.truthy? execute("SELECT pg_terminate_backend(#{pid.to_i})").first["pg_terminate_backend"]
      end

      def kill_long_running_queries
        long_running_queries.each { |query| kill(query["pid"]) }
        true
      end

      def kill_all
        select_all <<-SQL
          SELECT
            pg_terminate_backend(procpid)
          FROM
            pg_stat_activity
          WHERE
            procpid <> pg_backend_pid()
            AND current_query <> '<insufficient privilege>'
            AND datname = current_database()
        SQL
        true
      end
    end
  end
end
