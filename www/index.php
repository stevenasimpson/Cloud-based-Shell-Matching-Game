<!DOCTYPE html>
<html>
<head>
    <title>Shell Matching Game</title>
    <style>
        table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
            padding: 10px;
        }
        td {
            cursor: pointer;
        }
        .selected {
            background-color: yellow;
        }
        img {
            max-width: 100px;
        }
    </style>
</head>
<body>
    <h1>Match the Name to the Shell</h1>
    <p>Click on a name, then click on the matching image.</p>



    <table>
        <tr>
            <th>Names</th>
            <th>Shell Images</th>
        </tr>
        <tr>
            <td>
                <ul id="nameList"></ul>
            </td>
            <td>
                <ul id="imageList"></ul>
            </td>
        </tr>
    </table>

    <form id="addForm">
        <h2>Add New Shell</h2>
        <label>Code: <input type="text" name="code" required></label>
        <label>Name: <input type="text" name="name" required></label>
        <label>Image URL: <input type="text" name="img" required></label>
        <button type="submit">Add</button>
    </form>

    <p id="message"></p>

    <script>

        const API = "http://192.168.56.13:8888";

        fetch(API)
            .then(res => res.json())
            .then(data => {
                window.artifacts = data;
                fillLists(data);
            });

        function fillLists(artifacts){
            const names = artifacts.map(a => `<li data-code="${a.code}">${a.name}</li>`).join('');
            const shuffled = artifacts.slice().sort(() => Math.random() - 0.5);
            const images = shuffled.map(a => `<li data-code="${a.code}"><img src="${a.img}" alt="${a.name}"></li>`).join('');

            document.getElementById('nameList').innerHTML = names;
            document.getElementById('imageList').innerHTML = images;

            addEventListeners();

        }
        
        let selectedName = null;
        const messageEl = document.getElementById('message');
        
        function addEventListeners() {
            document.querySelectorAll('#nameList li').forEach(li => {
                li.addEventListener('click', () => {
                    clearSelections();
                    li.classList.add('selected');
                    selectedName = { code: li.getAttribute('data-code'), name: li.textContent };
                    messageEl.textContent = `Selected name: ${selectedName.name}. Now click the matching image.`;
                });
            });

            document.querySelectorAll('#imageList li').forEach(li => {
                li.addEventListener('click', () => {
                    if (!selectedName) {
                        alert('Please select a name first!');
                        return;
                    }
                    const imageCode = li.getAttribute('data-code');

                    // Call API to check the match
                   fetch(API, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ code: imageCode, name: selectedName.name })
                    })
                    .then(res => res.json())
                    .then(response => {
                        if (response.correct) {
                            messageEl.textContent = `Correct! ${selectedName.name} matches the shell.`;
                            removeMatched(selectedName.code);
                        } else {
                            messageEl.textContent = 'Wrong match. Try again!';
                        }
                        selectedName = null;
                        clearSelections();
                    });
                });
            });

        }

        document.getElementById('addForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const code = this.code.value.trim();
            const name = this.name.value.trim();
            const img = this.img.value.trim();

            fetch(API + '/add_artifact', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ code, name, img })
            })
            .then(res => res.json())
            .then(response => {
                if (response.success) {
                    messageEl.textContent = 'Shell added!';
                    fetch(API)
                        .then(res => res.json())
                        .then(data => {
                            window.artifacts = data;
                            fillLists(data);
                        });
                } else {
                    messageEl.textContent = 'Error: ' + response.error;
                }
            });
        });

        function clearSelections() {
            document.querySelectorAll('.selected').forEach(el => el.classList.remove('selected'));
        }

        function removeMatched(code) {
            // Remove matched items from the lists
            const nameItem = document.querySelector('#nameList li[data-code="' + code + '"]');
            const imageItem = document.querySelector('#imageList li[data-code="' + code + '"]');
            if (nameItem) nameItem.remove();
            if (imageItem) imageItem.remove();
        }
    </script>
</body>
</html>
