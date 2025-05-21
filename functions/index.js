const functions = require("firebase-functions");
const { exec } = require("child_process");

exports.predictCrop = functions.https.onRequest((req, res) => {
    // Convert incoming JSON request to string
    const inputData = JSON.stringify(req.body);

    // Run Python script with input data
    const process = exec("python3 functions/backend.py", { timeout: 5000 }, (error, stdout, stderr) => {
        if (error) {
            res.status(500).json({ error: error.message });
            return;
        }
        if (stderr) {
            res.status(500).json({ error: stderr });
            return;
        }

        try {
            const output = JSON.parse(stdout);  // Parse JSON output from Python
            res.json(output);
        } catch (err) {
            res.status(500).json({ error: "Invalid response from Python script" });
        }
    });

    // Send input data to Python script via stdin
    process.stdin.write(inputData);
    process.stdin.end();
});
