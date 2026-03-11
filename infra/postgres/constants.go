package postgres

import "time"

// TODO: move to configurationcode
const defaultMaxConnections = int32(7) // sized for around 3 cores
const defaultMinConnections = int32(0)
const defaultMaxConnLifetime = time.Hour
const defaultMaxConnIdleTime = time.Minute * 30
const defaultHealthCheckPeriod = time.Minute
const defaultConnectTimeout = time.Second * 5
