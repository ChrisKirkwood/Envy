import tkinter as tk
from tkinter import ttk, messagebox
from tkcalendar import Calendar
import pandas as pd
import os

class CalendarApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Schedule Calendar")
        self.root.geometry("800x600")

        self.calendar = Calendar(self.root, selectmode='day', year=2023, month=7, day=14)
        self.calendar.pack(pady=20)

        self.event_frame = tk.Frame(self.root)
        self.event_frame.pack(pady=20)

        self.event_label = tk.Label(self.event_frame, text="Event: ")
        self.event_label.pack(side=tk.LEFT)
        self.event_entry = tk.Entry(self.event_frame, width=30)
        self.event_entry.pack(side=tk.LEFT, padx=10)

        self.category_label = tk.Label(self.event_frame, text="Category: ")
        self.category_label.pack(side=tk.LEFT)
        self.category_combobox = ttk.Combobox(self.event_frame, values=["Work", "Personal", "Study"])
        self.category_combobox.pack(side=tk.LEFT, padx=10)

        self.add_button = tk.Button(self.root, text="Add Event", command=self.add_event)
        self.add_button.pack(pady=10)

        self.view_button = tk.Button(self.root, text="View Events", command=self.view_events)
        self.view_button.pack(pady=10)

        self.save_button = tk.Button(self.root, text="Save Calendar", command=self.save_calendar)
        self.save_button.pack(pady=10)

        self.load_button = tk.Button(self.root, text="Load Calendar", command=self.load_calendar)
        self.load_button.pack(pady=10)

        self.events = []

    def add_event(self):
        date = self.calendar.get_date()
        event = self.event_entry.get()
        category = self.category_combobox.get()
        if event and category:
            self.events.append({"Date": date, "Event": event, "Category": category})
            messagebox.showinfo("Event Added", f"Event '{event}' added to {date} under category '{category}'.")
        else:
            messagebox.showwarning("Input Error", "Please enter both event and category.")

    def view_events(self):
        date = self.calendar.get_date()
        events_on_date = [event for event in self.events if event["Date"] == date]
        if events_on_date:
            events_str = "\n".join([f"{event['Event']} ({event['Category']})" for event in events_on_date])
            messagebox.showinfo(f"Events on {date}", events_str)
        else:
            messagebox.showinfo(f"No Events on {date}", "No events found on this date.")

    def save_calendar(self):
        df = pd.DataFrame(self.events)
        df.to_excel("calendar_events.xlsx", index=False)
        messagebox.showinfo("Calendar Saved", "Calendar events saved to calendar_events.xlsx.")

    def load_calendar(self):
        if os.path.exists("calendar_events.xlsx"):
            df = pd.read_excel("calendar_events.xlsx")
            self.events = df.to_dict('records')
            messagebox.showinfo("Calendar Loaded", "Calendar events loaded from calendar_events.xlsx.")
        else:
            messagebox.showwarning("File Not Found", "No saved calendar events found.")

if __name__ == "__main__":
    root = tk.Tk()
    app = CalendarApp(root)
    root.mainloop()
