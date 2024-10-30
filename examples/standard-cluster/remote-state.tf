terraform {
  backend "gcs" {
    bucket = "<YOUR_GCS_STATE_BUCKET>"
    prefix = ""
  }
}
