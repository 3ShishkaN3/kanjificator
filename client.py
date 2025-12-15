import tkinter as tk
import requests
import time
from threading import Thread

API_URL = "http://localhost:5200/recognize"
CANVAS_SIZE = 300
LINE_WIDTH = 4

class KanjiPad:
    def __init__(self, root):
        self.root = root
        self.root.title("Zinnia Kanjificator")

        self.main_frame = tk.Frame(root)
        self.main_frame.pack(padx=10, pady=10)

        self.canvas = tk.Canvas(self.main_frame, width=CANVAS_SIZE, height=CANVAS_SIZE, bg="white", cursor="pencil")
        self.canvas.pack(side=tk.LEFT, padx=10)

        self.right_panel = tk.Frame(self.main_frame)
        self.right_panel.pack(side=tk.LEFT, fill=tk.Y)
        
        self.clear_btn = tk.Button(self.right_panel, text="Clear", command=self.clear_canvas, height=2, width=10)
        self.clear_btn.pack(pady=5)

        self.results_list = tk.Listbox(self.right_panel, font=("Arial", 18), height=10, width=15)
        self.results_list.pack(pady=5)

        # Structure of data: [ [(x,y), (x,y)...], [(x,y)...] ]
        self.strokes = [] 
        self.current_stroke = []

        self.canvas.bind("<Button-1>", self.start_stroke)
        self.canvas.bind("<B1-Motion>", self.add_point)
        self.canvas.bind("<ButtonRelease-1>", self.end_stroke)

    def start_stroke(self, event):
        self.current_stroke = [(event.x, event.y)]
        
    def add_point(self, event):
        if self.current_stroke:
            x1, y1 = self.current_stroke[-1]
            x2, y2 = event.x, event.y
            self.canvas.create_line(x1, y1, x2, y2, width=LINE_WIDTH, capstyle=tk.ROUND, smooth=True)
            self.current_stroke.append((x2, y2))

    def end_stroke(self, event):
        if self.current_stroke:
            self.strokes.append(self.current_stroke)
            self.current_stroke = []
            Thread(target=self.send_request).start()

    def clear_canvas(self):
        self.canvas.delete("all")
        self.strokes = []
        self.results_list.delete(0, tk.END)

    def send_request(self):
        payload = {
            "width": CANVAS_SIZE,
            "height": CANVAS_SIZE,
            "strokes": self.strokes
        }
        
        try:
            response = requests.post(API_URL, json=payload)
            if response.status_code == 200:
                candidates = response.json()
                self.update_results(candidates)
            else:
                print("Server Error:", response.status_code)
        except Exception as e:
            print("Connection Error:", e)

    def update_results(self, candidates):
        def _update():
            self.results_list.delete(0, tk.END)
            for item in candidates:
                display_text = f"{item['value']} ({item['score']:.3f})"
                self.results_list.insert(tk.END, display_text)
        
        self.root.after(0, _update)

if __name__ == "__main__":
    root = tk.Tk()
    app = KanjiPad(root)
    root.mainloop()