package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

func main() {
	projectDir := "./jeweler"
	cmd := exec.Command("pnpm", "run", "build")
	cmd.Dir = projectDir

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	err := cmd.Run()
	if err != nil {
		fmt.Printf("Failed to build the React project: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("React project built successfully!")

	// AWS S3にアップロード
	buildDir := filepath.Join(projectDir, "build")
	err = uploadDirToS3(buildDir, "jeweler-storage")
	if err != nil {
		fmt.Printf("Failed to upload to S3: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("Files uploaded to S3 successfully!")
}

func uploadDirToS3(dir, bucket string) error {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-west-2"),
	})
	if err != nil {
		return err
	}

	s3svc := s3.New(sess)

	err = filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if !info.IsDir() {
			file, err := os.Open(path)
			if err != nil {
				return err
			}
			defer file.Close()

			_, err = s3svc.PutObject(&s3.PutObjectInput{
				Bucket: aws.String(bucket),
				Key:    aws.String(path[len(dir)+1:]), // S3内のパス
				Body:   file,
			})
			if err != nil {
				return err
			}
		}

		return nil
	})

	return err
}
