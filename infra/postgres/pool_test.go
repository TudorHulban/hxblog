package postgres

import (
	"context"
	"fmt"
	"io/fs"
	"os"
	"testing"

	"github.com/TudorHulban/pgtestdb"
	"github.com/stretchr/testify/require"
)

// see https://medium.com/@neelkanthsingh.jr/understanding-database-connection-pools-and-the-pgx-library-in-go-3087f3c5a0c

func TestPGX(t *testing.T) {
	pgTest := pgtestdb.PGTestDB{
		ConnectionURL: fmt.Sprintf(
			"postgres://%s:%s@%s:%s/%s?",
			DBUser,
			DBPassword,
			DBHost,
			DBPort,
			"",
		),

		MigrationDirectories: []fs.FS{
			os.DirFS("../../migrations"),
		},

		T: t,
	}

	dbName, cleanUp := pgTest.Execute()
	defer cleanUp()

	ctx := context.Background()

	connPool, errCr := NewPGXPool(
		ctx,
		&ParamsDBConnection{
			DBName: dbName,

			DBHost: DBHost,
			DBPort: DBPort,

			DBUser:     DBUser,
			DBPassword: DBPassword,
		},
	)
	require.NoError(t, errCr)
	require.NotNil(t, connPool)

	defer connPool.Close()

	connection, errAcquire := connPool.Acquire(ctx)
	require.NoError(t, errAcquire)
	require.NotNil(t, connection)

	defer connection.Release()

	require.NoError(t,
		connection.Ping(ctx),
	)
}
