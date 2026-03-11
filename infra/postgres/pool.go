package postgres

import (
	"context"
	"os"

	"github.com/TudorHulban/log"
	"github.com/TudorHulban/log/timestamp"
	goerrors "github.com/tudorhulban/go-errors"
	"github.com/tudorhulban/hxhelpers"

	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

type ParamsDBConnection struct {
	DBName string

	DBHost string
	DBPort string

	DBUser     string
	DBPassword string

	NameApplication string
	EnableOnNotice  bool
}

func NewPGXPool(ctx context.Context, params *ParamsDBConnection) (*pgxpool.Pool, error) {
	connString := hxhelpers.Sprintf(
		"postgres://%s:%s@%s:%s/%s",

		params.DBUser,
		params.DBPassword,
		params.DBHost,
		params.DBPort,
		params.DBName,
	)

	dbConfig, errConfig := pgxpool.ParseConfig(connString)
	if errConfig != nil {
		return nil,
			goerrors.ErrInvalidInput{
				Caller:     "NewPGXPool",
				Issue:      errConfig,
				InputName:  "ParamsDBConnection",
				InputValue: params,
			}
	}

	if params.EnableOnNotice {
		dbConfig.ConnConfig.RuntimeParams["application_name"] = params.NameApplication

		l := log.NewLogger(
			&log.ParamsNewLogger{
				LoggerLevel:  log.LevelDEBUG,
				LoggerWriter: os.Stdout,

				WithTimestamp: timestamp.TimestampNano,
				WithCaller:    true,
				WithColor:     true,
			},
		)

		dbConfig.ConnConfig.OnNotice = func(_ *pgconn.PgConn, notice *pgconn.Notice) {
			l.Infof(
				"NOTICE(%s): %s",

				params.NameApplication,
				notice.Message,
			)
		}
	}

	dbConfig.MaxConns = defaultMaxConnections
	dbConfig.MinConns = defaultMinConnections
	dbConfig.MaxConnLifetime = defaultMaxConnLifetime
	dbConfig.MaxConnIdleTime = defaultMaxConnIdleTime
	dbConfig.HealthCheckPeriod = defaultHealthCheckPeriod
	dbConfig.ConnConfig.ConnectTimeout = defaultConnectTimeout

	connPool, errConn := pgxpool.NewWithConfig(ctx, dbConfig)
	if errConn != nil {
		return nil,
			goerrors.ErrInfrastructure{
				Caller:             "NewPGXPool",
				NameInfrastructure: "pgx - pool",
				Issue:              errConn,
			}
	}

	if errPing := connPool.Ping(ctx); errPing != nil {
		return nil,
			goerrors.ErrInfrastructure{
				Caller:             "NewPGXPool",
				NameInfrastructure: "pgx - ping",
				Issue:              errPing,
			}
	}

	return connPool,
		nil
}
