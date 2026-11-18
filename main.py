"""Kivy entry point for the Android employee manager."""

from kivy.app import App
from kivy.metrics import dp
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.scrollview import ScrollView
from kivy.uix.textinput import TextInput


employees = []


class EmployeeManagerApp(App):
    def build(self):
        self.title = "Employee App"
        layout = BoxLayout(
            orientation="vertical",
            padding=dp(16),
            spacing=dp(10),
        )

        heading = Label(
            text="إدارة الموظفين",
            font_size="24sp",
            size_hint_y=None,
            height=dp(48),
            halign="right",
            valign="middle",
        )
        layout.add_widget(heading)

        self.name_input = self._make_input("أدخل اسم الموظف")
        self.position_input = self._make_input("أدخل المسمى الوظيفي")
        self.department_input = self._make_input("أدخل القسم")
        layout.add_widget(self.name_input)
        layout.add_widget(self.position_input)
        layout.add_widget(self.department_input)

        add_button = Button(
            text="إضافة موظف جديد",
            size_hint_y=None,
            height=dp(48),
        )
        add_button.bind(on_press=self.add_employee)
        layout.add_widget(add_button)

        show_button = Button(
            text="عرض جميع الموظفين",
            size_hint_y=None,
            height=dp(48),
        )
        show_button.bind(on_press=self.show_employees)
        layout.add_widget(show_button)

        self.message = Label(
            text="",
            size_hint_y=None,
            height=dp(40),
            halign="right",
            valign="middle",
        )
        self.message.bind(
            width=lambda label, width: setattr(label, "text_size", (width, None))
        )
        layout.add_widget(self.message)

        self.employee_list = Label(
            text="لا يوجد موظفون مسجلون حالياً.",
            size_hint_y=None,
            halign="right",
            valign="top",
        )
        self.employee_list.bind(
            width=lambda label, width: setattr(label, "text_size", (width, None))
        )
        self.employee_list.bind(
            texture_size=lambda label, size: setattr(label, "height", size[1])
        )
        scroll_view = ScrollView()
        scroll_view.add_widget(self.employee_list)
        layout.add_widget(scroll_view)

        exit_button = Button(
            text="خروج",
            size_hint_y=None,
            height=dp(48),
        )
        exit_button.bind(on_press=lambda *_: self.stop())
        layout.add_widget(exit_button)

        return layout

    @staticmethod
    def _make_input(hint):
        return TextInput(
            hint_text=hint,
            multiline=False,
            size_hint_y=None,
            height=dp(48),
        )

    def add_employee(self, *_):
        name = self.name_input.text
        employee = {
            "name": name,
            "position": self.position_input.text,
            "department": self.department_input.text,
        }
        employees.append(employee)

        self.message.text = f"تم إضافة الموظف {name} بنجاح!"
        self.name_input.text = ""
        self.position_input.text = ""
        self.department_input.text = ""
        self.show_employees()

    def show_employees(self, *_):
        if not employees:
            self.employee_list.text = "لا يوجد موظفون مسجلون حالياً."
            return

        lines = ["--- قائمة الموظفين ---"]
        for index, employee in enumerate(employees, start=1):
            lines.append(
                f"{index}. الاسم: {employee['name']} | "
                f"الوظيفة: {employee['position']} | "
                f"القسم: {employee['department']}"
            )
        self.employee_list.text = "\n".join(lines)


if __name__ == "__main__":
    EmployeeManagerApp().run()
